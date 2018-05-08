# == Schema Information
#
# Table name: rotations
#
#  id                 :bigint(8)        not null, primary key
#  community_id       :bigint(8)        not null
#  description        :string           default(""), not null
#  color              :string           not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  residents_notified :boolean          default(FALSE), not null
#  start_date         :date
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
  attributes :start,
             :end,
             :color,
             :title,
             :url

  def start
    object.meals.order(:date).first.date
  end

  def end
    object.meals.order(:date).last.date + 1.day # b/c FullCalendar date ranges are exclusive
  end

  def title
    "Rotation #{object.id}"
  end

  def url
    "/rotations/#{object.id}"
  end

end
