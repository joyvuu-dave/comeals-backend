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

class GuestRoomReservationSerializer < ActiveModel::Serializer
  include ApplicationHelper

  attributes :id,
             :type,
             :title,
             :start,
             :end,
             :url,
             :description,
             :color

  def id
    object.cache_key_with_version
  end

  def type
    object.class.to_s
  end

  def title
    "Guest Room\n#{resident_name_helper(object.resident.name)} - Unit #{object.resident.unit.name}"
  end

  def description
    "Guest Room\n#{resident_name_helper(object.resident.name)} - Unit #{object.resident.unit.name}"
  end

  def start
    object.date + 1.minute
  end

  def end
    object.date + 1.minute
  end

  def url
    "guest-room-reservations/edit/#{object.id}"
  end

  def color
    "#bc7335"
  end

end
