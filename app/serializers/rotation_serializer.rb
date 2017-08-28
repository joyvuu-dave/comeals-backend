class RotationSerializer < ActiveModel::Serializer
  cache key: 'rotation'
  attributes :start,
             :end,
             :color,
             :title,
             :url

  def start
    object.meals.first.date
  end

  def end
    object.meals.last.date + 1.day # b/c FullCalendar date ranges are exclusive
  end

  def title
    "Rotation #{object.id}"
  end

  def url
    "/rotations/#{object.id}"
  end

end
