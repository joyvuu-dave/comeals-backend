# == Schema Information
#
# Table name: meals
#
#  id                        :integer          not null, primary key
#  date                      :date             not null
#  cap                       :integer
#  meal_residents_count      :integer          default(0), not null
#  guests_count              :integer          default(0), not null
#  bills_count               :integer          default(0), not null
#  cost                      :integer          default(0), not null
#  meal_residents_multiplier :integer          default(0), not null
#  guests_multiplier         :integer          default(0), not null
#  description               :text
#  max                       :integer
#  community_id              :integer          not null
#  reconciliation_id         :integer
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#
# Indexes
#
#  index_meals_on_community_id       (community_id)
#  index_meals_on_reconciliation_id  (reconciliation_id)
#
# Foreign Keys
#
#  fk_rails_...  (community_id => communities.id)
#  fk_rails_...  (reconciliation_id => reconciliations.id)
#

class Meal < ApplicationRecord
  scope :unreconciled, -> { where(reconciliation_id: nil) }

  belongs_to :community
  belongs_to :reconciliation, optional: true

  has_many :bills, dependent: :destroy
  has_many :meal_residents, inverse_of: :meal, dependent: :destroy
  has_many :guests, inverse_of: :meal, dependent: :destroy
  has_many :residents, through: :meal_residents

  validates :date, presence: true
  validates :community, presence: true
  validates :max, numericality: { only_integer: true }, unless: Proc.new { |a| a.max.nil? }

  accepts_nested_attributes_for :guests, allow_destroy: true, reject_if: proc { |attributes| attributes['name'].blank? }
  accepts_nested_attributes_for :bills, allow_destroy: true, reject_if: proc { |attributes| attributes['resident_id'].blank? }

  def cap
    read_attribute(:cap) || Float::INFINITY
  end

  # DERIVED DATA
  def multiplier
    meal_residents_multiplier + guests_multiplier
  end

  def attendees
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
  def max_cost
    cap * multiplier
  end

  # TEST
  def balanced?
    bills.map(&:reimburseable_amount).inject(0, :+) == modified_cost
  end

  def whats_wrong
    return nil if diff == 0

    message = diff > 0 ?
      "more collected than given to cooks." :
      "more given to cooks than collected."

    "#{diff} #{message}"
  end

  def diff
    collected - modified_cost
  end

  def naive_unit_cost
    (cost / multiplier.to_f).ceil
  end

  # Report Methods
  def self.unreconciled_ave_cost
    val = 2 * ((Meal.unreconciled.pluck(:cost).reduce(&:+).to_i / Meal.unreconciled.reduce(0) { |sum, meal| sum + meal.multiplier }.to_f) / 100.to_f)
    val.nan? ? '--' : "$#{sprintf('%0.02f', val)}/adult"
  end

  def self.unreconciled_ave_number_of_attendees
    val = (Meal.unreconciled.reduce(0) { |sum, meal| sum + meal.attendees } / Meal.unreconciled.count.to_f).round(1)
    val.nan? ? '--' : val
  end

  def self.create_templates(community_id, start_date, end_date, alternating_dinner_day, num_meals_created)
    # Are we finished?
    return num_meals_created if start_date >= end_date

    # Is it a common dinner day?
    if [alternating_dinner_day, 2, 4].any? { |num| num == start_date.wday }
      # Flip if alternating dinner day
      if start_date.wday == alternating_dinner_day
        alternating_dinner_day = (alternating_dinner_day - 1) ** 2
      end

      community = Community.find(community_id)

      # if Meal.new(date: start_date, cap: community.cap, community_id: community_id).save
      #   num_meals_created += 1
      # end
      if meal = Meal.new(date: start_date, cap: community.cap, community_id: community_id).save
        num_meals_created += 1
      else
        Rails.logger.info meal.errors
      end

      # If common dinner was on a Sunday, we
      # don't have dinner the next day
      start_date += 24.hour if start_date.wday == 0

      start_date += 24.hour
      return create_templates(community_id, start_date, end_date, alternating_dinner_day, num_meals_created)
    end

    start_date += 24.hour
    return create_templates(community_id, start_date, end_date, alternating_dinner_day, num_meals_created)
  end
end
