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
#  description               :text
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
    modifier = object.balanced? ? nil : "(#{object.id}#{object.subsidized? ? "*" : nil})"

    Date.today > object.date ?
      "#{modifier} Dinner: #{object.attendees} present" :
      object.max ?
        "#{modifier} Dinner: #{object.max} max (#{object.max - object.attendees} left)" :
        "#{modifier} Dinner: no max"
  end

  def start
    object.date
  end

  def url
    "/meals/#{object.id}/edit"
  end
end
