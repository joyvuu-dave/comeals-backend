# == Schema Information
#
# Table name: common_house_reservations
#
#  id           :bigint(8)        not null, primary key
#  community_id :bigint(8)        not null
#  resident_id  :bigint(8)        not null
#  start_date   :datetime         not null
#  end_date     :datetime         not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  title        :string
#
# Indexes
#
#  index_common_house_reservations_on_community_id  (community_id)
#  index_common_house_reservations_on_resident_id   (resident_id)
#
# Foreign Keys
#
#  fk_rails_...  (community_id => communities.id)
#  fk_rails_...  (resident_id => residents.id)
#

FactoryBot.define do
  factory :common_house_reservation do
    community 
    resident 
    start_date { 72.hours.ago }
    end_date { 71.hours.ago }
  end
end
