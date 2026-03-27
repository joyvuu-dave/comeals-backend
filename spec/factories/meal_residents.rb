# == Schema Information
#
# Table name: meal_residents
#
#  id           :bigint           not null, primary key
#  meal_id      :bigint           not null
#  resident_id  :bigint           not null
#  community_id :bigint           not null
#  multiplier   :integer          not null
#  vegetarian   :boolean          default(FALSE), not null
#  late         :boolean          default(FALSE), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

FactoryBot.define do
  factory :meal_resident do
    meal
    resident
    community
    multiplier { 2 }
  end
end
