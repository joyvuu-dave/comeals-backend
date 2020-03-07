# == Schema Information
#
# Table name: rotations
#
#  id                 :bigint           not null, primary key
#  color              :string           not null
#  description        :string           default(""), not null
#  place_value        :integer
#  residents_notified :boolean          default("false"), not null
#  start_date         :date
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  community_id       :bigint           not null
#
# Indexes
#
#  index_rotations_on_community_id  (community_id)
#
# Foreign Keys
#
#  fk_rails_...  (community_id => communities.id)
#

class RotationSerializer < ActiveModel::Serializer
  attributes :id,
             :type,
             :start,
             :end,
             :color,
             :title,
             :url

  def id
    object.cache_key_with_version
  end

  def type
    object.class.to_s
  end

  def start
    object.meals.order(:date).first.date + 1.minute
  end

  def end
    object.meals.order(:date).last.date + 1.day - 1.minute # b/c ReactBigCalendar date ranges are exclusive
  end

  def title
    "Rotation #{object.place_value}"
  end

  def url
    "rotations/show/#{object.id}"
  end

end
