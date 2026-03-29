# == Schema Information
#
# Table name: reconciliations
#
#  id           :bigint           not null, primary key
#  date         :date             not null
#  end_date     :date             not null
#  start_date   :date             not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  community_id :bigint           not null
#
# Indexes
#
#  index_reconciliations_on_community_id  (community_id)
#
# Foreign Keys
#
#  fk_rails_...  (community_id => communities.id)
#
class Reconciliation < ApplicationRecord
  has_many :meals, dependent: :nullify
  has_many :bills, through: :meals
  has_many :cooks, through: :bills, source: :resident
  has_many :reconciliation_balances, dependent: :destroy
  belongs_to :community

  validates :start_date, presence: true
  validates :end_date, presence: true
  validate :start_date_not_after_end_date

  before_validation :set_date
  after_create :finalize

  def number_of_meals
    meals.count
  end

  def unique_cooks
    cooks.uniq
  end

  # Assigns unreconciled meals (with at least one bill) within the date range.
  def assign_meals
    meal_ids = Meal.where(community_id: community_id)
                   .unreconciled
                   .joins(:bills)
                   .where(date: start_date..end_date)
                   .distinct
                   .pluck(:id)
    Meal.where(id: meal_ids).update_all(reconciliation_id: id)
  end

  # Compute final settlement balances for this reconciliation period.
  # Returns a hash of { resident_id => rounded_balance }.
  # Uses banker's rounding (ROUND_HALF_EVEN) per financial standards.
  #
  # This method batch-loads all data upfront (5 queries total) to avoid the N+1
  # that would result from calling Meal#unit_cost per-record. The arithmetic is
  # identical to the per-record path (Meal#unit_cost, MealResident#cost, etc.)
  # but computed from in-memory data.
  #
  # Memory: loads all reconciled meals + associations into RAM. For a co-housing
  # community (~500 meals max), this is ~18K AR objects (~36 MB). Bounded by the
  # physical size of the community.
  def settlement_balances
    # Step 1: Eager-load all reconciled meals with their financial associations.
    # Uses preload (not includes) to guarantee separate IN(?) queries — includes
    # can silently switch to LEFT JOIN if a .where is later chained on an
    # included table, which would produce a cartesian product across 3 associations.
    reconciled_meals = meals.with_attendees.preload(:bills, :meal_residents, :guests).to_a

    # Step 2: Precompute unit_cost per meal from in-memory data.
    # Uses block-form .sum(&:field) which invokes Enumerable#sum on the loaded
    # array. The column-form .sum(:field) always fires SQL even when loaded.
    unit_costs = {}
    reconciled_meals.each do |meal|
      total_mult = meal.meal_residents.sum(&:multiplier) + meal.guests.sum(&:multiplier)

      if total_mult == 0
        unit_costs[meal.id] = BigDecimal("0")
        next
      end

      total_cost = meal.bills.reject(&:no_cost).sum(BigDecimal("0"), &:amount)
      effective_cost = total_cost
      if meal.capped?
        max_cost = meal.cap * total_mult
        effective_cost = max_cost if total_cost > max_cost
      end

      unit_costs[meal.id] = effective_cost / total_mult
    end

    # Step 3: Accumulate credits, debits, and guest debits from in-memory data.
    # All three use the already-loaded associations — zero additional queries.
    credits_by_resident = Hash.new(BigDecimal("0"))
    debits_by_resident = Hash.new(BigDecimal("0"))
    guest_debits_by_resident = Hash.new(BigDecimal("0"))

    reconciled_meals.each do |meal|
      uc = unit_costs[meal.id]
      meal.bills.each { |b| credits_by_resident[b.resident_id] += b.amount unless b.no_cost }
      meal.meal_residents.each { |mr| debits_by_resident[mr.resident_id] += uc * mr.multiplier }
      meal.guests.each { |g| guest_debits_by_resident[g.resident_id] += uc * g.multiplier }
    end

    # Step 4: Assemble per-resident balances (1 query for residents, zero inside loop).
    balances = {}
    community.residents.find_each do |resident|
      credits = credits_by_resident[resident.id]
      debits = debits_by_resident[resident.id]
      guest_debits = guest_debits_by_resident[resident.id]
      raw_balance = credits - debits - guest_debits

      # Round to cents using banker's rounding (ROUND_HALF_EVEN)
      balances[resident.id] = raw_balance.round(2, BigDecimal::ROUND_HALF_EVEN)
    end

    # Verify the books balance: total credits should equal total debits.
    # Zero-attendee meals are already excluded (with_attendees scope), so the
    # only source of imbalance is banker's rounding — at most 0.5 cents per
    # resident. Anything beyond that is a calculation bug.
    total = balances.values.reduce(BigDecimal("0"), :+)
    theoretical_max = BigDecimal("0.005") * balances.size
    if total.abs > theoretical_max
      raise "settlement_balances: books do not balance for reconciliation #{id}. " \
            "Discrepancy: #{total} exceeds theoretical rounding maximum of #{theoretical_max}. " \
            "This indicates a bug in cost calculations."
    end

    balances
  end

  # Persist settlement balances to reconciliation_balances table.
  # Only stores non-zero balances to keep the table lean.
  def persist_balances!
    balances = settlement_balances
    balances.each do |resident_id, amount|
      next if amount.zero?
      reconciliation_balances.create!(resident_id: resident_id, amount: amount)
    end
  end

  def balance_for(resident)
    reconciliation_balances.find_by(resident_id: resident.id)&.amount || BigDecimal("0")
  end

  private

  def finalize
    assign_meals
    persist_balances!
  end

  def set_date
    self.date ||= Date.today
  end

  def start_date_not_after_end_date
    return unless start_date.present? && end_date.present?
    errors.add(:start_date, "must be on or before end date") if start_date > end_date
  end
end
