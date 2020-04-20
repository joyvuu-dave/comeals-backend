class MealFormSerializer < ActiveModel::Serializer
  attributes :id,
             :description,
             :max,
             :closed,
             :closed_at,
             :date,
             :reconciled,
             :next_id,
             :prev_id

  def reconciled
    # TODO: remove temporary override to allow editing
    #scope.reconciled?
    false
  end

  def next_id
    meals = Meal.where(community_id: scope.community_id).order(:date)
    meal_index = meals.find_index { |meal| meal.id == scope.id }

    # Scenario #1: This is the last meal
    next_index = meal_index if meal_index == meals.size - 1

    # Scenario #2: This is NOT the last meal
    next_index = meal_index + 1 if meal_index < meals.size - 1

    meals[next_index].id
  end

  def prev_id
    meals = Meal.where(community_id: scope.community_id).order(:date)
    meal_index = meals.find_index { |meal| meal.id == scope.id }

    # Scenario #1: This is the first meal
    previous_index = meal_index if meal_index == 0

    # Scenario #2: This is NOT the first meal
    previous_index = meal_index - 1 if meal_index > 0

    meals[previous_index].id
  end

  has_many :bills
  has_many :residents
  has_many :guests

  class BillSerializer < ActiveModel::Serializer
    attributes :resident_id,
               :amount_cents,
               :no_cost
  end

  class ResidentSerializer < ActiveModel::Serializer
    attributes :id,
               :meal_id,
               :name,
               :attending,
               :attending_at,
               :late,
               :vegetarian,
               :can_cook,
               :active

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
