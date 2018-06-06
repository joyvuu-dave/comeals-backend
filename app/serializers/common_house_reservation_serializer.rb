# == Schema Information
#
# Table name: common_house_reservations
#
#  id           :bigint(8)        not null, primary key
#  community_id :bigint(8)        not null
#  resident_id  :bigint(8)        not null
#  start_date   :datetime         not null
#  end_date     :datetime         not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  title        :string
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

  attributes :id,
             :type,
             :title,
             :start,
             :end,
             :url,
             :description

  def id
    object.cache_key_with_version
  end

  def type
    object.class.to_s
  end

  def title
    "\nCommon House\n#{object.title.present? ? "#{object.title}\n" : ''}#{resident_name_helper(object.resident.name)} - Unit #{object.resident.unit.name}"
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
    "common-house-reservations/edit/#{object.id}"
  end
end
