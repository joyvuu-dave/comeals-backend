# == Schema Information
#
# Table name: meals
#
#  id                        :bigint           not null, primary key
#  date                      :date             not null
#  cap                       :decimal(12, 8)
#  meal_residents_count      :integer          default(0), not null
#  guests_count              :integer          default(0), not null
#  bills_count               :integer          default(0), not null
#  meal_residents_multiplier :integer          default(0), not null
#  guests_multiplier         :integer          default(0), not null
#  description               :text             default(""), not null
#  max                       :integer
#  closed                    :boolean          default(FALSE), not null
#  community_id              :bigint           not null
#  reconciliation_id         :bigint
#  rotation_id               :bigint
#  closed_at                 :datetime
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  start_time                :datetime         not null
#

FactoryBot.define do
  factory :meal do
    community
    date  { Faker::Date.backward(days: 365) }
  end
end
