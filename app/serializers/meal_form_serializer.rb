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
    scope.reconciliation_id.present?
  end

  def next_id
    # Next meal by date, or self if this is the last meal
    Meal.where(community_id: scope.community_id)
        .where("date > ? OR (date = ? AND id > ?)", scope.date, scope.date, scope.id)
        .order(:date, :id).limit(1).pick(:id) || scope.id
  end

  def prev_id
    # Previous meal by date, or self if this is the first meal
    Meal.where(community_id: scope.community_id)
        .where("date < ? OR (date = ? AND id < ?)", scope.date, scope.date, scope.id)
        .order(date: :desc, id: :desc).limit(1).pick(:id) || scope.id
  end

  has_many :bills
  has_many :residents
  has_many :guests

  # Override residents to include inactive residents who attended this meal.
  # Without this, deactivated residents (moved/deceased) vanish from old meals
  # they actually attended. The union: all active community residents (for the
  # signup dropdown) + any inactive residents with a meal_resident record.
  def residents
    community_residents = Resident.where(community_id: object.community_id)
    community_residents
      .where(active: true)
      .or(community_residents.where(id: object.meal_residents.select(:resident_id)))
      .includes(:unit)
  end

  class BillSerializer < ActiveModel::Serializer
    attributes :resident_id,
               :amount,
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
