# == Schema Information
#
# Table name: meals
#
#  id                        :bigint(8)        not null, primary key
#  date                      :date             not null
#  cap                       :integer
#  meal_residents_count      :integer          default(0), not null
#  guests_count              :integer          default(0), not null
#  bills_count               :integer          default(0), not null
#  cost                      :integer          default(0), not null
#  meal_residents_multiplier :integer          default(0), not null
#  guests_multiplier         :integer          default(0), not null
#  description               :text             default(""), not null
#  max                       :integer
#  closed                    :boolean          default(FALSE), not null
#  community_id              :bigint(8)        not null
#  reconciliation_id         :bigint(8)
#  rotation_id               :bigint(8)
#  closed_at                 :datetime
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  start_time                :datetime         not null
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
  attributes :title,
             :start,
             :url,
             :description

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
    object.date
  end

  def url
    "/meals/#{object.id}/edit"
  end
end
