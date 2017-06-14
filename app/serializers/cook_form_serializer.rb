class CookFormSerializer < ActiveModel::Serializer
  cache key: 'cook_form'
  attributes :id,
             :description,
             :max,
             :closed

  has_many :bills
  has_many :residents

  class BillSerializer < ActiveModel::Serializer
    attributes :resident_id,
               :amount_cents
  end

  class ResidentSerializer < ActiveModel::Serializer
    attributes :id,
               :name
  end
end
