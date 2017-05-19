# == Schema Information
#
# Table name: guests
#
#  id          :integer          not null, primary key
#  meal_id     :integer          not null
#  resident_id :integer          not null
#  multiplier  :integer          default(2), not null
#  name        :string           not null
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
  belongs_to :meal, inverse_of: :guests
  belongs_to :resident

  counter_culture :meal
  counter_culture :meal, column_name: 'guests_multiplier', delta_column: 'multiplier'

  validates :name, presence: true
  validates :meal, presence: true
  validates :resident, presence: true
  validates :multiplier, numericality: { only_integer: true }

  def cost
    meal.unit_cost * multiplier
  end
end
