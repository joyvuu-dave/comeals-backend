# frozen_string_literal: true

# == Schema Information
#
# Table name: common_house_reservations
#
#  id           :bigint           not null, primary key
#  end_date     :datetime         not null
#  start_date   :datetime         not null
#  title        :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  community_id :bigint           not null
#  resident_id  :bigint           not null
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
             :description,
             :color

  def id
    object.cache_key_with_version
  end

  def type
    object.class.to_s
  end

  def title
    time_range = "#{object.start_date.strftime('%l:%M%P')} - " \
                 "#{object.end_date.strftime('%l:%M%P')}"
    title_line = "#{object.title}\n" if object.title.present?
    name = resident_name_helper(object.resident.name)
    unit_name = object.resident.unit.name
    "#{time_range}\nCommon House\n#{title_line}#{name} - Unit #{unit_name}"
  end

  def description
    "Common House\n#{resident_name_helper(object.resident.name)} - Unit #{object.resident.unit.name}"
  end

  def start
    object.start_date + 1.minute
  end

  def end
    object.end_date + 1.minute
  end

  def url
    "common-house-reservations/edit/#{object.id}"
  end

  def color
    '#bc357e'
  end
end
