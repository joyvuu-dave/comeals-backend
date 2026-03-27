# == Schema Information
#
# Table name: bills
#
#  id           :bigint           not null, primary key
#  meal_id      :bigint           not null
#  resident_id  :bigint           not null
#  community_id :bigint           not null
#  amount       :decimal(12, 8)   default(0.0), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  no_cost      :boolean          default(FALSE), not null
#

FactoryBot.define do
  factory :bill do
    meal
    resident
    community
    amount { BigDecimal(Random.rand(9.0..99.0).round(2).to_s) }
  end
end
