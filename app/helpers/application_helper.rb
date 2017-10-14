module ApplicationHelper
  def category_helper(multiplier)
    return "Child" if multiplier == 1
    return "Adult" if multiplier == 2
    return "#{multiplier/2.to_f} Adult"
  end

  def resident_name_helper(name)
    first = name.split(' ')[0]
    last = name.split(' ')[1]

    names = Resident.pluck(:name).map { |name| name.split(' ')[0] }

    # Scenario #1: Name is just a first name (already unique)
    return name if last.nil?

    # Scenario #2: first name is unique
    return first if names.count(first) == 1

    # Scenario #3: first name is not unique
    # FIXME: doesn't guarantee unique string
    return "#{first} #{last[0]}"
  end

  def parse_audit(audit)
    return parse_meal_audit(audit) if audit.auditable_type == 'Meal'
    return parse_bill_audit(audit) if audit.auditable_type == 'Bill'
    return parse_meal_resident_audit(audit) if audit.auditable_type == 'MealResident'
    return parse_guest_audit(audit) if audit.auditable_type == 'Guest'
  end

  def parse_meal_audit(audit)
    return 'Meal record created' if audit.action == 'create'
    return 'Meal record deleted' if audit.action == 'destroy'

    if audit.action == 'update'
      changes = audit.audited_changes

      # Meal Opened / Closed
      if changes["closed"].class == Array
        return "Meal closed" if changes["closed"][1] == true
        return "Meal opened" if changes["closed"][0] == true
        return "#{audit.auditable_type}, #{audit.action}"
      end

      # Meal Description Updated
      return "Menu description updated" if changes["description"].present?

      # Extras Count Changed
      if changes["max"].class == Array
        initial = changes["max"][0]
        final = changes["max"][1]

        # Extras set for first time
        return "Extras count set" if initial.nil?

        # Extras value reset
        return "Extras count cleared" if final.nil?

        # Extras count increased
        return "Extras count increased by #{final - initial}" if final > initial

        # Extras count decreased
        return "Extras count decreasesd by #{initial - final}" if initial > final

        # Shouldn't happen?
        return "Extras count set"
      end

      # Meal added to Rotation
      return "Meal assigned to a rotation" if changes["rotation_id"].present?

      # Other
      return "#{audit.auditable_type}, #{audit.action}"
    end

    return "Meal, #{audit.action}" # Shouldn't happen?
  end

  def parse_bill_audit(audit)
    changes = audit.audited_changes
    resident = Resident.find_by(id: changes["resident_id"])
    name = resident.present? ? resident_name_helper(resident.name) : "unknown"
    bill = Bill.find_by(id: audit.auditable_id)

    return "#{name} added as cook" if audit.action == 'create'
    return "#{name} removed as cook" if audit.action == 'destroy'
    return "Bill for #{resident_name_helper(bill.resident.name)} changed from #{number_to_currency(changes["amount_cents"][0].to_f / 100)} to #{number_to_currency(changes["amount_cents"][1].to_f / 100)}" if audit.action == 'update'
    return "#{audit.auditable_type}, #{audit.action}"
  end

  def parse_meal_resident_audit(audit)
    changes = audit.audited_changes
    if audit.action == "update"
      resident = MealResident.find_by(id: audit.auditable_id)&.resident
    else
      resident = Resident.find_by(id: changes["resident_id"])
    end

    name = resident.present? ? resident_name_helper(resident.name) : "unknown"

    return "#{name} added" if audit.action == 'create'
    return "#{name} removed" if audit.action == 'destroy'

    if audit.action == 'update'
      if changes["late"].class == Array
        return "#{name} marked late" if changes["late"][0] == false && changes["late"][1] == true
        return "#{name} marked not late" if changes["late"][0] == true && changes["late"][1] == false
        return "#{audit.auditable_type}, #{audit.action}"
      end

      if changes["vegetarian"].class == Array
        return "#{name} marked veg" if changes["vegetarian"][0] == false && changes["vegetarian"][1] == true
        return "#{name} marked not veg" if changes["vegetarian"][0] == false && changes["vegetarian"][1] == true
        return "#{audit.auditable_type}, #{audit.action}"
      end

      return "#{audit.auditable_type}, #{audit.action}"
    end

    return "#{audit.auditable_type}, #{audit.action}"
  end

  def parse_guest_audit(audit)
    changes = audit.audited_changes
    resident = Resident.find_by(id: changes["resident_id"])
    name = resident.present? ? resident_name_helper(resident.name) : "unknown"

    if audit.action == 'create'
      return "Veg guest of #{name} added" if changes["vegetarian"] == true
      return "Omnivore guest of #{name} added" if changes["vegetarian"] == false
      return "#{audit.auditable_type}, #{audit.action}"
    end

    if audit.action == 'destroy'
      return "Veg guest of #{name} removed" if changes["vegetarian"] == true
      return "Omnivore guest of #{name} removed" if changes["vegetarian"] == false
      return "#{audit.auditable_type}, #{audit.action}"
    end

    return "#{audit.auditable_type}, #{audit.action}"
  end

end
