# == Schema Information
#
# Table name: guest_room_reservations
#
#  id           :integer          not null, primary key
#  community_id :integer          not null
#  resident_id  :integer          not null
#  date         :date             not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_guest_room_reservations_on_community_id  (community_id)
#  index_guest_room_reservations_on_resident_id   (resident_id)
#
# Foreign Keys
#
#  fk_rails_...  (community_id => communities.id)
#  fk_rails_...  (resident_id => residents.id)
#

class GuestRoomReservation < ApplicationRecord
  belongs_to :community
  belongs_to :resident

  validates_uniqueness_of :date, { scope: :community_id }
end
