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

class CommonHouseReservation < ApplicationRecord
  belongs_to :community
  belongs_to :resident

  validates_presence_of :resident
  validates_presence_of :start_date
  validates_presence_of :end_date
end
