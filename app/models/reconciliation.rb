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
    Meal.where(community_id: community_id)
        .unreconciled
        .joins(:bills)
        .distinct
        .where(date: start_date..end_date)
        .update_all(reconciliation_id: id)
  end

  # Compute final settlement balances for this reconciliation period.
  # Returns a hash of { resident_id => rounded_balance }.
  # Uses banker's rounding (ROUND_HALF_EVEN) per financial standards.
  def settlement_balances
    balances = {}

    community.residents.find_each do |resident|
      credits = resident.bills.joins(:meal).where(meals: { reconciliation_id: id })
                        .where(no_cost: false).sum(:amount)

      debits = resident.meal_residents.joins(:meal).where(meals: { reconciliation_id: id })
                       .sum(&:cost)

      guest_debits = resident.guests.joins(:meal).where(meals: { reconciliation_id: id })
                             .sum(&:cost)

      raw_balance = credits - debits - guest_debits

      # Round to cents using banker's rounding (ROUND_HALF_EVEN)
      balances[resident.id] = raw_balance.round(2, BigDecimal::ROUND_HALF_EVEN)
    end

    # Verify the books balance: total credits should equal total debits.
    # Rounding can introduce at most 0.5 cents per resident, so tolerance scales with resident count.
    total = balances.values.reduce(BigDecimal("0"), :+)
    tolerance = BigDecimal("0.01") * balances.size
    if total.abs > tolerance
      Rails.logger.warn("settlement_balances: books do not balance for reconciliation #{id}. " \
                        "Discrepancy: #{total}. This likely indicates a bug in cost calculations.")
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
