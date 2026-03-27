# == Schema Information
#
# Table name: guest_room_reservations
#
#  id           :bigint           not null, primary key
#  community_id :bigint           not null
#  resident_id  :bigint           not null
#  date         :date             not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

FactoryBot.define do
  factory :guest_room_reservation do
    community
    resident
    date { 7.days.ago }
  end
end
