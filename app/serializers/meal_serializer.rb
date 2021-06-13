# == Schema Information
#
# Table name: meals
#
#  id                        :bigint           not null, primary key
#  bills_count               :integer          default(0), not null
#  cap                       :integer
#  closed                    :boolean          default(FALSE), not null
#  closed_at                 :datetime
#  cost                      :integer          default(0), not null
#  date                      :date             not null
#  description               :text             default(""), not null
#  guests_count              :integer          default(0), not null
#  guests_multiplier         :integer          default(0), not null
#  max                       :integer
#  meal_residents_count      :integer          default(0), not null
#  meal_residents_multiplier :integer          default(0), not null
#  start_time                :datetime         not null
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  community_id              :bigint           not null
#  reconciliation_id         :bigint
#  rotation_id               :bigint
#
# Indexes
#
#  index_meals_on_community_id           (community_id)
#  index_meals_on_date_and_community_id  (date,community_id) UNIQUE
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
      message << " attended"
      return message
    end

    if Time.zone.today == object.date
      message << " attending"
    end

    if Time.zone.today < object.date
      message << " signed up"
    end

    if object.max.present?
      count = object.max - object.attendees_count
      message << "\n #{count} extra#{count == 1 ? '' : 's'}"
    end

    return message
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
    "#444"
  end
end
