

class CommonHouseReservationSerializer < ActiveModel::Serializer
  include ApplicationHelper
  cache key: 'chr'
  attributes :title,
             :start,
             :end,
             :url,
             :description

  def title
    "\nCommon House\n#{resident_name_helper(object.resident.name)} - Unit #{object.resident.unit.name}"
  end

  def description
    "Common House\n#{resident_name_helper(object.resident.name)} - Unit #{object.resident.unit.name}"
  end

  def start
    object.start_date
  end

  def end
    object.end_date
  end

  def url
    "/common-house-reservations/#{object.id}/edit"
  end
end
