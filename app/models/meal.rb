# frozen_string_literal: true

# == Schema Information
#
# Table name: meals
#
#  id                :bigint           not null, primary key
#  cap               :decimal(12, 8)
#  closed            :boolean          default(FALSE), not null
#  closed_at         :datetime
#  date              :date             not null
#  description       :text             default(""), not null
#  max               :integer
#  start_time        :datetime         not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  community_id      :bigint           not null
#  reconciliation_id :bigint
#  rotation_id       :bigint
#
# Indexes
#
#  index_meals_on_community_id           (community_id)
#  index_meals_on_date_and_community_id  (date,community_id) UNIQUE
#  index_meals_on_reconciliation_id      (reconciliation_id)
#  index_meals_on_rotation_id            (rotation_id)
#
# Foreign Keys
#
#  fk_rails_...  (community_id => communities.id)
#  fk_rails_...  (reconciliation_id => reconciliations.id)
#  fk_rails_...  (rotation_id => rotations.id)
#
class Meal < ApplicationRecord
  # Ransack allowlists for ActiveAdmin filtering and sorting
  def self.ransackable_attributes(_auth_object = nil)
    %w[id cap closed closed_at community_id created_at date description max reconciliation_id rotation_id start_time
       updated_at]
  end

  ALTERNATING_DAYS = [1, 2].freeze
  TEMPLATE_WDAYS = [0, 4].freeze

  audited
  has_associated_audits

  attr_accessor :socket_id

  scope :unreconciled, -> { where(reconciliation_id: nil) }
  scope :open, -> { where(closed: false) }
  scope :closed_with_bills, -> { where(closed: true).joins(:bills).distinct }

  # Meals where at least one person ate (meal_resident or guest).
  # A bill on a meal with no attendees has zero financial impact —
  # the cook absorbs the cost and is not reimbursed.
  # Uses EXISTS (not JOIN) to avoid multiplying rows in SUM queries.
  scope :with_attendees, lambda {
    mr = MealResident.arel_table
    g = Guest.arel_table
    where(
      MealResident.where(mr[:meal_id].eq(arel_table[:id])).arel.exists
        .or(Guest.where(g[:meal_id].eq(arel_table[:id])).arel.exists)
    )
  }

  belongs_to :community
  belongs_to :reconciliation, optional: true
  belongs_to :rotation, optional: true

  has_many :bills, inverse_of: :meal, dependent: :destroy
  has_many :cooks, through: :bills, source: :resident
  has_many :meal_residents, inverse_of: :meal, dependent: :destroy
  has_many :guests, inverse_of: :meal, dependent: :destroy
  has_many :hosts, through: :guests, source: :resident
  has_many :attendees, through: :meal_residents, source: :resident
  has_many :residents, -> { where active: true }, through: :community

  before_validation :set_start_time, on: :create

  validates :date, presence: true
  validates :max,
            numericality: {
              greater_than_or_equal_to: :attendees_count,
              message: "Max can't be less than current number of attendees."
            },
            allow_nil: true

  validates :date, uniqueness: { scope: :community_id }

  before_save :conditionally_set_max
  before_save :conditionally_set_closed_at
  before_create :set_cap

  accepts_nested_attributes_for :guests, allow_destroy: true, reject_if: proc { |attributes| attributes['name'].blank? }
  accepts_nested_attributes_for :bills, allow_destroy: true, reject_if: proc { |attributes|
    attributes['resident_id'].blank?
  }

  def get_start_time # rubocop:disable Naming/AccessorMethodName -- frontend API expects get_start_time
    start_time.in_time_zone(community.timezone)
  end

  # NULL cap means "no cap". No more Float::INFINITY.
  def cap
    read_attribute(:cap)
  end

  def capped?
    cap.present?
  end

  def set_cap
    self.cap = community.cap
  end

  def set_start_time
    self.start_time = date.wday.zero? ? date.to_datetime + 18.hours : date.to_datetime + 19.hours
  end

  def conditionally_set_max
    self.max = nil if closed == false
  end

  def conditionally_set_closed_at
    self.closed_at = DateTime.now if closed == true && closed_was == false
    self.closed_at = nil if closed == false && closed_was == true
  end

  def trigger_pusher
    key = "meal-#{id}"

    # Delete Cache
    Rails.cache.delete(key)

    # Notify
    Pusher.trigger(
      key,
      'update',
      { message: 'meal updated' },
      { socket_id: socket_id }
    )

    # Update Calendar
    community.trigger_pusher(date)

    true
  end

  # DERIVED DATA — all computed from source, no cached columns.

  def multiplier
    meal_residents.sum(:multiplier) + guests.sum(:multiplier)
  end

  def attendees_count
    meal_residents.count + guests.count
  end

  delegate :count, to: :bills, prefix: true

  # Total cost computed from source bills via SQL SUM.
  # No memoization — bills can change within a request, and stale data
  # in financial calculations is worse than one cheap indexed query.
  def total_cost
    bills.where(no_cost: false).sum(:amount)
  end

  # The cost used for splitting after applying the cap.
  # If uncapped or under cap, this equals total_cost.
  # If over cap, this equals max_cost.
  def effective_total_cost
    tc = total_cost
    return tc unless capped?

    mc = max_cost
    [tc, mc].min
  end

  # Per-multiplier-unit cost. Single division, no per-bill iteration.
  def unit_cost
    return BigDecimal('0') if multiplier.zero?

    effective_total_cost / multiplier
  end

  # Total amount that would be collected from all attendees.
  def collected
    unit_cost * multiplier
  end

  # Maximum total cost for this meal based on the community cap.
  # Returns nil if uncapped.
  def max_cost
    return nil unless capped?

    cap * multiplier
  end

  def subsidized?
    return false if multiplier.zero?
    return false unless capped?

    total_cost > max_cost
  end

  def reconciled?
    reconciliation_id.present?
  end

  def total_audits
    (associated_audits + audits).sort { |a, b| b.created_at <=> a.created_at }
  end

  # HELPERS
  def another_meal_in_this_rotation_has_less_than_two_cooks?
    return false if rotation_id.nil?

    Meal.where(rotation_id: rotation_id).where.not(id: id)
        .left_joins(:bills)
        .group(:id)
        .having('COUNT(bills.id) < 2')
        .exists?
  end

  # *** This method only used during seed generation ***
  # Typical 3x a week schedule with alternating Mon / Tues
  def self.create_templates(community_id, start_date, end_date, alternating_dinner_day)
    count = 0
    Community.find(community_id)
    dates = (start_date..end_date).to_a

    dates.each do |date|
      # Skip holidays
      next if Meal.is_holiday?(date)

      # Skip days without dinner
      next unless [0, alternating_dinner_day, 4].any?(date.wday)

      # Flip the alternating dinner day
      if date.wday == alternating_dinner_day
        alternating_dinner_day = ALTERNATING_DAYS.find do |val|
          val != alternating_dinner_day
        end
      end

      # Create the meal
      meal = Meal.new(date: date, community_id: community_id)
      if meal.save
        count += 1
      else
        Rails.logger.debug meal.errors
      end
    end

    count
  end

  # *** This method only used during seed generation ***
  # Modified twice a week schedule
  def self.create_modified_templates(community_id, start_date, end_date)
    count = 0
    Community.find(community_id)
    dates = (start_date..end_date).to_a

    dates.each do |date|
      # Skip holidays
      next if Meal.is_holiday?(date)

      # Skip days without dinner
      next unless TEMPLATE_WDAYS.any?(date.wday)

      # Create the meal
      meal = Meal.new(date: date, community_id: community_id)
      if meal.save
        count += 1
      else
        Rails.logger.debug meal.errors
      end
    end

    count
  end

  def self.is_holiday?(date)
    return true if  Meal.is_thanksgiving(date)  ||
                    Meal.is_christmas(date)     ||
                    Meal.is_newyears(date)      ||
                    Meal.is_mothers_day(date)   ||
                    Meal.is_easter(date)        ||
                    Meal.is_july_fourth(date)

    false
  end

  def self.is_thanksgiving(date)
    return false unless date.instance_of?(Date)
    return false unless date.month == 11
    return false unless date.thursday?
    return false unless date.day.between?(22, 28)

    true
  end

  def self.is_christmas(date)
    return true if date.month == 12 && date.day == 25

    false
  end

  def self.is_newyears(date)
    return true if date.month == 1 && date.day == 1

    false
  end

  def self.is_mothers_day(date)
    return false unless date.instance_of?(Date)
    return false unless date.month == 5
    return false unless date.sunday?
    return false unless date.day.between?(8, 14)

    true
  end

  def self.is_easter(date) # rubocop:disable Metrics/AbcSize -- Anonymous Gregorian algorithm, inherently arithmetic-heavy
    y = date.year
    a = y % 19
    b = y / 100
    c = y % 100
    d = b / 4
    e = b % 4
    f = (b + 8) / 25
    g = (b - f + 1) / 3
    h = ((19 * a) + b - d - g + 15) % 30
    i = c / 4
    k = c % 4
    l = (32 + (2 * e) + (2 * i) - h - k) % 7
    m = (a + (11 * h) + (22 * l)) / 451

    month = (h + l - (7 * m) + 114) / 31
    day = ((h + l - (7 * m) + 114) % 31) + 1

    return true if date.month == month && date.day == day

    false
  end

  def self.is_july_fourth(date)
    return true if date.month == 7 && date.day == 4

    false
  end
end
