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

require 'rails_helper'

RSpec.describe GuestRoomReservation, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
