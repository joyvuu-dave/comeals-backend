# == Schema Information
#
# Table name: bills
#
#  id              :bigint           not null, primary key
#  amount_cents    :integer          default("0"), not null
#  amount_currency :string           default("USD"), not null
#  no_cost         :boolean          default("false"), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  community_id    :bigint           not null
#  meal_id         :bigint           not null
#  resident_id     :bigint           not null
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
      "Cook\n#{resident_name_helper(object.resident.name)} - Unit #{object.resident.unit.name}\n#{number_to_currency(object.amount_cents.to_f / 100)}" :
      "Cook\n#{resident_name_helper(object.resident.name)} - Unit #{object.resident.unit.name}"

  end

  def start
    object.meal.date + 1.minute
  end

  def end
    object.meal.date + 1.minute
  end

  def url
    "/meals/#{object.meal_id}/edit"
  end

  def description
    object.amount_cents > 0 && object.meal.date < Date.today ?
      "Cook:  #{resident_name_helper(object.resident.name)} - Unit #{object.resident.unit.name} - #{number_to_currency(object.amount_cents.to_f / 100)}" :
      "Cook:  #{resident_name_helper(object.resident.name)} - Unit #{object.resident.unit.name}"

  end
end
