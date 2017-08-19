class MealFormSerializer < ActiveModel::Serializer
  attributes :id,
             :description,
             :max,
             :closed,
             :closed_at,
             :date

  has_many :bills
  has_many :residents
  has_many :guests

  class BillSerializer < ActiveModel::Serializer
    attributes :resident_id,
               :amount_cents
  end

  class ResidentSerializer < ActiveModel::Serializer
    attributes :id,
               :meal_id,
               :name,
               :attending,
               :attending_at,
               :late,
               :vegetarian

    def meal_id
      scope.id
    end

    def attending
      meal_resident.present?
    end

    def attending_at
      meal_resident.present? ? meal_resident.created_at : nil
    end

    def name
      "#{object.unit.name} - #{object.name}"
    end

    def late
      meal_resident.present? ? meal_resident.late : false
    end

    def vegetarian
      meal_resident.present? ? meal_resident.vegetarian : object.vegetarian
    end

    private
    def meal_resident
      @meal_resident = MealResident.find_by(meal_id: scope.id, resident_id: object.id)
    end
  end

  class GuestSerializer < ActiveModel::Serializer
    attributes :id,
               :meal_id,
               :resident_id,
               :name,
               :vegetarian,
               :created_at
  end

end
