class GuestSerializer < ActiveModel::Serializer
    attributes :id,
               :meal_id,
               :resident_id,
               :name,
               :vegetarian,
               :created_at
end
