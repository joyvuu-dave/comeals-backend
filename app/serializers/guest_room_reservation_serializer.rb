

class GuestRoomReservationSerializer < ActiveModel::Serializer
  include ApplicationHelper
  cache key: 'grr'
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
