# == Schema Information
#
# Table name: guests
#
#  id          :bigint           not null, primary key
#  meal_id     :bigint           not null
#  resident_id :bigint           not null
#  multiplier  :integer          default(2), not null
#  name        :string           default(""), not null
#  vegetarian  :boolean          default(FALSE), not null
#  late        :boolean          default(FALSE), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

FactoryBot.define do
  factory :guest do
    meal
    resident
  end
end
