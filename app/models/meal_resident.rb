# == Schema Information
#
# Table name: meal_residents
#
#  id           :bigint(8)        not null, primary key
#  meal_id      :bigint(8)        not null
#  resident_id  :bigint(8)        not null
#  community_id :bigint(8)        not null
#  multiplier   :integer          not null
#  vegetarian   :boolean          default(FALSE), not null
#  late         :boolean          default(FALSE), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_meal_residents_on_community_id             (community_id)
#  index_meal_residents_on_meal_id                  (meal_id)
#  index_meal_residents_on_meal_id_and_resident_id  (meal_id,resident_id) UNIQUE
#  index_meal_residents_on_resident_id              (resident_id)
#
# Foreign Keys
#
#  fk_rails_...  (community_id => communities.id)
#  fk_rails_...  (meal_id => meals.id)
#  fk_rails_...  (resident_id => residents.id)
#

class MealResident < ApplicationRecord
  belongs_to :meal, inverse_of: :meal_residents, touch: true
  belongs_to :resident
  belongs_to :community

  audited associated_with: :meal

  before_validation :set_multiplier
  before_validation :set_community_id

  counter_culture :meal
  counter_culture :meal, column_name: 'meal_residents_multiplier', delta_column: 'multiplier'

  validates :meal, presence: true
  validates :resident, presence: true
  validates :community, presence: true
  validates_uniqueness_of :meal_id, { scope: :resident_id }
  validates :multiplier, numericality: { only_integer: true }
  validate :meal_has_open_spots, on: :create
  before_destroy :record_can_be_removed

  def meal_has_open_spots
    # Scenario: Meal is open
    return true if meal.closed == false

    # Scenario: Meal is closed, max has been set, there are open spots
    return true if meal.closed == true && meal.max.present? && meal.attendees_count < meal.max

    # Scenario: Meal is closed and, max has NOT been set
    errors.add(:base, "Meal has been closed.") if meal.closed == true && meal.max.nil?

    # Scenario: Meal is closed, max has been set, there are NOT open spots
    errors.add(:base, "Meal has no open spots.") if meal.closed == true && meal.max.present? && meal.attendees_count == meal.max
  end

  def record_can_be_removed
    # Scenario: Meal is open
    return true if meal.closed == false

    # Scenario: Meal is closed, resident signed up after meal was closed (there were extras)
    return true if meal.closed == true && created_at > meal.closed_at

    # Scenario: Meal is closed, resident signed up before meal was closed
    errors.add(:base, "Meal has been closed.") if meal.closed == true && created_at <= meal.closed_at
    false
    throw(:abort)
  end

  def set_multiplier
    self.multiplier = resident&.multiplier
  end

  def set_community_id
    self.community_id = meal&.community_id
  end

  def cost
    meal.unit_cost * multiplier
  end
end
