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

class GuestRoomReservationSerializer < ActiveModel::Serializer
  include ApplicationHelper

  attributes :title,
             :start,
             :url,
             :description

  def title
    "Guest Room\n#{resident_name_helper(object.resident.name)} - Unit #{object.resident.unit.name}"
  end

  def description
    "Guest Room\n#{resident_name_helper(object.resident.name)} - Unit #{object.resident.unit.name}"
  end

  def start
    object.date
  end

  def url
    "/guest-room-reservations/#{object.id}/edit"
  end
end
