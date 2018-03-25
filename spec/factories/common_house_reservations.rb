# == Schema Information
#
# Table name: common_house_reservations
#
#  id           :integer          not null, primary key
#  community_id :integer          not null
#  resident_id  :integer          not null
#  start_date   :datetime         not null
#  end_date     :datetime         not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
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
    community nil
    resident nil
    start_date "2018-03-13 10:25:09"
    end_date "2018-03-13 10:25:09"
  end
end
