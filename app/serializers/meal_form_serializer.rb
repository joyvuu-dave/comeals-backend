class MealFormSerializer < ActiveModel::Serializer
  attributes :id,
             :description,
             :max,
             :closed,
             :date

  has_many :bills
  has_many :residents

  class BillSerializer < ActiveModel::Serializer
    attributes :resident_id,
               :amount_cents
  end

  class ResidentSerializer < ActiveModel::Serializer
    attributes :id,
               :meal_id,
               :name,
               :attending,
               :late,
               :vegetarian,
               :guests

    def meal_id
      scope.id
    end

    def attending
      meal_resident.present?
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

    def guests
      Guest.where(meal_id: scope.id, resident_id: object.id).count
    end

    private
    def meal_resident
      @meal_resident = MealResident.find_by(meal_id: scope.id, resident_id: object.id)
    end
  end
end
