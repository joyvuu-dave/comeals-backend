# == Schema Information
#
# Table name: common_house_reservations
#
#  id           :integer          not null, primary key
#  community_id :integer          not null
#  resident_id  :integer          not null
#  start_date   :datetime         not null
#  end_date     :datetime         not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_common_house_reservations_on_community_id  (community_id)
#  index_common_house_reservations_on_resident_id   (resident_id)
#
# Foreign Keys
#
#  fk_rails_...  (community_id => communities.id)
#  fk_rails_...  (resident_id => residents.id)
#



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