# == Schema Information
#
# Table name: meals
#
#  id                        :bigint(8)        not null, primary key
#  date                      :date             not null
#  cap                       :integer
#  meal_residents_count      :integer          default(0), not null
#  guests_count              :integer          default(0), not null
#  bills_count               :integer          default(0), not null
#  cost                      :integer          default(0), not null
#  meal_residents_multiplier :integer          default(0), not null
#  guests_multiplier         :integer          default(0), not null
#  description               :text             default(""), not null
#  max                       :integer
#  closed                    :boolean          default(FALSE), not null
#  community_id              :bigint(8)        not null
#  reconciliation_id         :bigint(8)
#  rotation_id               :bigint(8)
#  closed_at                 :datetime
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  start_time                :datetime         not null
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
  audited
  has_associated_audits

  attr_accessor :socket_id

  scope :unreconciled, -> { where(reconciliation_id: nil) }

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
  validates :community, presence: true
  validates :max, numericality: { greater_than_or_equal_to: :attendees_count, message: "Max can't be less than current number of attendees." }, allow_nil: true

  validates_uniqueness_of :date, { scope: :community_id }

  before_create :set_cap
  before_save :conditionally_set_max
  before_save :conditionally_set_closed_at
  after_touch :mark_related_residents_dirty

  accepts_nested_attributes_for :guests, allow_destroy: true, reject_if: proc { |attributes| attributes['name'].blank? }
  accepts_nested_attributes_for :bills, allow_destroy: true, reject_if: proc { |attributes| attributes['resident_id'].blank? }

  def get_start_time
    self.start_time.in_time_zone(community.timezone)
  end

  def cap
    read_attribute(:cap) || Float::INFINITY
  end

  def set_cap
    self.cap = community.cap
  end

  def set_start_time
    self.start_time = date.wday == 0 ? date.to_datetime + 18.hours : date.to_datetime + 19.hours
  end

  def conditionally_set_max
    self.max = nil if closed == false
  end

  def conditionally_set_closed_at
    self.closed_at = DateTime.now if closed == true && closed_was == false
    self.closed_at = nil if closed == false && closed_was == true
  end

  def mark_related_residents_dirty
    cooks.update_all(balance_is_dirty: true)
    attendees.update_all(balance_is_dirty: true)
    hosts.update_all(balance_is_dirty: true)
  end

  def trigger_pusher
    Pusher.trigger(
      "meal-#{id}",
      'update',
      { message: 'meal updated' },
      { socket_id: socket_id }
    )
    return true
  end

  # DERIVED DATA
  def multiplier
    meal_residents_multiplier + guests_multiplier
  end

  def attendees_count
    meal_residents_count + guests_count
  end

  def modified_cost
    bills.map(&:reimburseable_amount).inject(0, :+)
  end

  def unit_cost
    bills.map(&:unit_cost).inject(0, :+)
  end

  def collected
    unit_cost * multiplier
  end

  def subsidized?
    return false if multiplier == 0
    cost > max_cost
  end

  def reconciled?
    reconciliation_id.present?
  end

  # HELPERS
  def another_meal_in_this_rotation_has_less_than_two_cooks?
    Meal.where(rotation_id: rotation_id).where.not(id: id).pluck(:bills_count).any? { |num| num < 2 }
  end

  def max_cost
    cap * multiplier
  end

  def self.create_templates(community_id, start_date, end_date, alternating_dinner_day)
    count = 0
    community = Community.find(community_id)
    dates = (start_date..end_date).to_a

    dates.each do |date|
      # Skip holidays
      next if Meal.is_holiday?(date)

      # Skip days without dinner
      next unless [0, alternating_dinner_day, 4].any? { |num| num == date.wday }

      # Flip the alternating dinner day
      alternating_dinner_day = [1, 2].find { |val| val != alternating_dinner_day } if date.wday == alternating_dinner_day

      # Create the meal
      meal = Meal.new(date: date, community_id: community_id)
      if meal.save
        count += 1
      else
        puts meal.errors.to_s
      end
    end

    count
  end

  def self.is_holiday?(date)
    return true if Meal.is_thanksgiving(date) || Meal.is_christmas(date) || Meal.is_newyears(date) || Meal.is_mothers_day(date) || Meal.is_easter(date)
    false
  end

  def self.is_thanksgiving(date)
    return false unless date.class == Date
    return false unless date.month == 11
    return false unless date.thursday?
    return false unless date.day >= 22 && date.day <= 28
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
    return false unless date.class == Date
    return false unless date.month == 5
    return false unless date.sunday?
    return false unless date.day >= 8 && date.day <= 14
    true
  end

  def self.is_easter(date)
    y = date.year
    a = y % 19
    b = y / 100
    c = y % 100
    d = b / 4
    e = b % 4
    f = (b + 8) / 25
    g = (b - f + 1) / 3
    h = (19 * a + b - d - g + 15) % 30
    i = c / 4
    k = c % 4
    l = (32 + 2 * e + 2 * i - h - k) % 7
    m = (a + 11 * h + 22 * l) / 451

    month = (h + l - 7 * m + 114) / 31
    day = ((h + l - 7 * m + 114) % 31) + 1

    return true if date.month == month && date.day == day
    false
  end

end
