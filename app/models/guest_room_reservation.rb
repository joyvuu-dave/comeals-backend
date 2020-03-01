# == Schema Information
#
# Table name: guest_room_reservations
#
#  id           :bigint           not null, primary key
#  date         :date             not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  community_id :bigint           not null
#  resident_id  :bigint           not null
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

  validates_presence_of :resident
  validates_presence_of :date
  validates_uniqueness_of :date, { scope: :community_id }

  after_commit :trigger_pusher

  def trigger_pusher
    community.trigger_pusher(self.date)
  end

end
