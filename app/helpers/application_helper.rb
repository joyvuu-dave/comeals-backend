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

end
