# == Schema Information
#
# Table name: common_house_reservations
#
#  id           :bigint           not null, primary key
#  community_id :bigint           not null
#  resident_id  :bigint           not null
#  start_date   :datetime         not null
#  end_date     :datetime         not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  title        :string
#

FactoryBot.define do
  factory :common_house_reservation do
    community 
    resident 
    start_date { 72.hours.ago }
    end_date { 71.hours.ago }
  end
end
