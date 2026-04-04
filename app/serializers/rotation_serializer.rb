# frozen_string_literal: true

# == Schema Information
#
# Table name: rotations
#
#  id                 :bigint           not null, primary key
#  color              :string           not null
#  description        :string           default(""), not null
#  place_value        :integer
#  residents_notified :boolean          default(FALSE), not null
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
    first_date = if object.meals.loaded?
                   object.meals.min_by(&:date)&.date
                 else
                   object.meals.minimum(:date)
                 end
    first_date&.+(1.minute)
  end

  def end
    last_date = if object.meals.loaded?
                  object.meals.max_by(&:date)&.date
                else
                  object.meals.maximum(:date)
                end
    last_date && (last_date + 1.day - 1.minute) # ReactBigCalendar date ranges are exclusive
  end

  def title
    "Rotation #{object.place_value}"
  end

  def url
    "rotations/show/#{object.id}"
  end
end
