# == Schema Information
#
# Table name: guests
#
#  id          :bigint(8)        not null, primary key
#  meal_id     :bigint(8)        not null
#  resident_id :bigint(8)        not null
#  multiplier  :integer          default(2), not null
#  name        :string           default(""), not null
#  vegetarian  :boolean          default(FALSE), not null
#  late        :boolean          default(FALSE), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_guests_on_meal_id      (meal_id)
#  index_guests_on_resident_id  (resident_id)
#
# Foreign Keys
#
#  fk_rails_...  (meal_id => meals.id)
#  fk_rails_...  (resident_id => residents.id)
#

class Guest < ApplicationRecord
  belongs_to :meal, inverse_of: :guests, touch: true
  belongs_to :resident

  audited associated_with: :meal

  counter_culture :meal
  counter_culture :meal, column_name: 'guests_multiplier', delta_column: 'multiplier'

  validates :meal, presence: true
  validates :resident, presence: true
  validates :multiplier, numericality: { only_integer: true }
  validate :meal_has_open_spots

  def meal_has_open_spots
    errors.add(:base, "Meal has no open spots.") unless meal.max.nil? || meal.attendees_count < meal.max
  end

  def cost
    meal.unit_cost * multiplier
  end

end
