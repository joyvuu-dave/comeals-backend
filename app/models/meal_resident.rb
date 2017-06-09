# == Schema Information
#
# Table name: meal_residents
#
#  id           :integer          not null, primary key
#  meal_id      :integer          not null
#  resident_id  :integer          not null
#  community_id :integer          not null
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
  belongs_to :meal, inverse_of: :meal_residents
  belongs_to :resident
  belongs_to :community

  before_validation :set_multiplier
  before_validation :set_community_id

  counter_culture :meal, execute_after_commit: true
  counter_culture :meal, column_name: 'meal_residents_multiplier', delta_column: 'multiplier'

  validates :meal, presence: true
  validates :resident, presence: true
  validates :community, presence: true
  validates_uniqueness_of :meal_id, { scope: :resident_id }
  validates :multiplier, numericality: { only_integer: true }

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
