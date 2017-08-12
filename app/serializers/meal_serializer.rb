# == Schema Information
#
# Table name: meals
#
#  id                        :integer          not null, primary key
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
#  community_id              :integer          not null
#  reconciliation_id         :integer
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#
# Indexes
#
#  index_meals_on_community_id       (community_id)
#  index_meals_on_reconciliation_id  (reconciliation_id)
#
# Foreign Keys
#
#  fk_rails_...  (community_id => communities.id)
#  fk_rails_...  (reconciliation_id => reconciliations.id)
#

class MealSerializer < ActiveModel::Serializer
  cache key: 'meal'
  attributes :title,
             :start,
             :url,
             :description

  def title
    if Date.today > object.date
      return "#{object.attendees_count} attended dinner"
    end

    if Date.today <= object.date && object.max.present?
      count = object.max - object.attendees_count

      return "#{object.attendees_count} signed up, #{count} extra#{count == 1 ? '' : 's'}"
    end

    if Date.today <= object.date && object.max.nil?
      return "#{object.attendees_count} signed up"
    end
  end

  def start
    object.date
  end

  def url
    "/meals/#{object.id}/edit"
  end
end
