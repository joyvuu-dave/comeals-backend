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

FactoryBot.define do
  factory :guest do
    meal
    resident
  end
end
