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
