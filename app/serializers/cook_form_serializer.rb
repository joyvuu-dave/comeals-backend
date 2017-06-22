class CookFormSerializer < ActiveModel::Serializer
  cache key: 'cook_form'
  attributes :id,
             :description,
             :max,
             :closed

  has_many :bills
  has_many :residents

  def description
    object.description.nil? ? "" : object.description
  end

  def max
    object.max.nil? ? 40 : object.max
  end

  def bills
    array = object.bills.to_a
    (3 - object.bills.count).times do
      array.concat([Bill.new])
    end
    array
  end

  class BillSerializer < ActiveModel::Serializer
    attributes :resident_id,
               :amount_cents

    def resident_id
      object.resident_id.nil? ? -1 : object.resident_id
    end
  end

  class ResidentSerializer < ActiveModel::Serializer
    attributes :id,
               :name
  end
end
