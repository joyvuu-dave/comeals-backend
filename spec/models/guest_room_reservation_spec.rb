# == Schema Information
#
# Table name: guest_room_reservations
#
#  id           :bigint(8)        not null, primary key
#  community_id :bigint(8)        not null
#  resident_id  :bigint(8)        not null
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

require 'rails_helper'

RSpec.describe GuestRoomReservation, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
