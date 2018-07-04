class ResidentBirthdaySerializer < ActiveModel::Serializer
  include ApplicationHelper

  attributes :id,
             :type,
             :title,
             :description,
             :start,
             :end,
             :color

  def id
    object.cache_key_with_version
  end

  def type
    "Birthday"
  end

  def title
    object.age < 22 ?
      "#{resident_name_helper(object.name)}'s #{object.age.ordinalize} B-day!"
      :
      "#{resident_name_helper(object.name)}'s B-day!"
  end

  def description
    object.age < 22 ?
      "#{resident_name_helper(object.name)}'s #{object.age.ordinalize} Birthday!"
      :
      "#{resident_name_helper(object.name)}'s Birthday!"
  end

  def start
    Date.new(Date.today.year, (object.birthday + 1.day).month, (object.birthday + 1.day).day)
  end

  def end
    Date.new(Date.today.year, (object.birthday + 1.day).month, (object.birthday + 1.day).day)
  end

  def color
    "#7335bc"
  end

end
