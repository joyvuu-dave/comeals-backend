# frozen_string_literal: true

# == Schema Information
#
# Table name: meals
#
#  id                :bigint           not null, primary key
#  cap               :decimal(12, 8)
#  closed            :boolean          default(FALSE), not null
#  closed_at         :datetime
#  date              :date             not null
#  description       :text             default(""), not null
#  max               :integer
#  start_time        :datetime         not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  community_id      :bigint           not null
#  reconciliation_id :bigint
#  rotation_id       :bigint
#
# Indexes
#
#  index_meals_on_community_id_and_date  (community_id,date) UNIQUE
#  index_meals_on_reconciliation_id      (reconciliation_id)
#  index_meals_on_rotation_id            (rotation_id)
#
# Foreign Keys
#
#  fk_rails_...  (community_id => communities.id)
#  fk_rails_...  (reconciliation_id => reconciliations.id)
#  fk_rails_...  (rotation_id => rotations.id)
#

class MealSerializer < ActiveModel::Serializer
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
    message = "Dinner\n#{object.attendees_count}"

    if Time.zone.today > object.date
      message << ' attended'
      return message
    end

    message << ' attending' if Time.zone.today == object.date

    message << ' signed up' if Time.zone.today < object.date

    if object.max.present?
      count = object.max - object.attendees_count
      message << "\n #{count} extra#{'s' unless count == 1}"
    end

    message
  end

  def start
    object.date + 1.minute
  end

  def end
    object.date + 1.minute
  end

  def url
    "/meals/#{object.id}/edit"
  end

  def color
    '#444'
  end
end
