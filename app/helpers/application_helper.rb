module ApplicationHelper
  def category_helper(multiplier)
    return "Child" if multiplier == 1
    return "Adult" if multiplier == 2
    return "#{multiplier/2.to_f} Adult"
  end

  def guest_count_string_helper(meal, resident)
    guest_count = meal.guests.where(resident_id: resident.id).count

    name_string = "#{resident&.name} - #{resident&.unit&.name}"
    name_string += " (1 guest)" if guest_count == 1
    name_string += " (#{guest_count} guests)" if guest_count > 1

    name_string
  end

  def format_rotation_length(val)
    return 'unset' unless val
    return "#{val} meal" if val == 1
    return "#{val} meals"
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
    return "#{first} #{last[0]}"
  end
end
