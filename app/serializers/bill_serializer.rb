# == Schema Information
#
# Table name: bills
#
#  id           :bigint           not null, primary key
#  meal_id      :bigint           not null
#  resident_id  :bigint           not null
#  community_id :bigint           not null
#  amount       :decimal(12, 8)   default(0.0), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  no_cost      :boolean          default(FALSE), not null
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
    object.amount > 0 && object.meal.date < Date.today ?
      "Cook\n#{resident_name_helper(object.resident.name)} - Unit #{object.resident.unit.name}\n#{number_to_currency(object.amount)}" :
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
    object.amount > 0 && object.meal.date < Date.today ?
      "Cook:  #{resident_name_helper(object.resident.name)} - Unit #{object.resident.unit.name} - #{number_to_currency(object.amount)}" :
      "Cook:  #{resident_name_helper(object.resident.name)} - Unit #{object.resident.unit.name}"

  end
end
