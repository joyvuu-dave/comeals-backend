# frozen_string_literal: true

# == Schema Information
#
# Table name: bills
#
#  id           :bigint           not null, primary key
#  amount       :decimal(12, 8)   default(0.0), not null
#  no_cost      :boolean          default(FALSE), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  community_id :bigint           not null
#  meal_id      :bigint           not null
#  resident_id  :bigint           not null
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
    if object.amount.positive? && object.meal.date < Time.zone.today
      name = resident_name_helper(object.resident.name)
      unit_name = object.resident.unit.name
      "Cook\n#{name} - Unit #{unit_name}\n#{number_to_currency(object.amount)}"
    else
      "Cook\n#{resident_name_helper(object.resident.name)} - Unit #{object.resident.unit.name}"
    end
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
    if object.amount.positive? && object.meal.date < Time.zone.today
      name = resident_name_helper(object.resident.name)
      unit_name = object.resident.unit.name
      "Cook:  #{name} - Unit #{unit_name} - #{number_to_currency(object.amount)}"
    else
      "Cook:  #{resident_name_helper(object.resident.name)} - Unit #{object.resident.unit.name}"
    end
  end
end
