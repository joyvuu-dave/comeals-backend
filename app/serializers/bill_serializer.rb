# == Schema Information
#
# Table name: bills
#
#  id              :bigint(8)        not null, primary key
#  meal_id         :bigint(8)        not null
#  resident_id     :bigint(8)        not null
#  community_id    :bigint(8)        not null
#  amount_cents    :integer          default(0), not null
#  amount_currency :string           default("USD"), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_bills_on_community_id             (community_id)
#  index_bills_on_meal_id                  (meal_id)
#  index_bills_on_meal_id_and_resident_id  (meal_id,resident_id) UNIQUE
#  index_bills_on_resident_id              (resident_id)
#
# Foreign Keys
#
#  fk_rails_...  (community_id => communities.id)
#  fk_rails_...  (meal_id => meals.id)
#  fk_rails_...  (resident_id => residents.id)
#

class BillSerializer < ActiveModel::Serializer
  include ApplicationHelper
  include ActiveSupport::NumberHelper

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
    object.amount_cents > 0 && object.meal.date < Date.today ?
      "Cook\n#{resident_name_helper(object.resident.name)} - Unit #{object.resident.unit.name}\n#{number_to_currency(object.amount_cents / 100)}" :
      "Cook\n#{resident_name_helper(object.resident.name)} - Unit #{object.resident.unit.name}"

  end

  def start
    object.meal.date
  end

  def end
    object.meal.date
  end

  def url
    "/meals/#{object.meal_id}/edit"
  end

  def description
    object.amount_cents > 0 && object.meal.date < Date.today ?
      "Cook:  #{resident_name_helper(object.resident.name)} - Unit #{object.resident.unit.name} - #{number_to_currency(object.amount_cents / 100)}" :
      "Cook:  #{resident_name_helper(object.resident.name)} - Unit #{object.resident.unit.name}"

  end
end
