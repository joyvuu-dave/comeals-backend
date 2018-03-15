class ResidentBirthdaySerializer < ActiveModel::Serializer
  include ApplicationHelper

  cache key: 'resident_birthday'
  attributes :title,
             :description,
             :start

  def title
    object.age < 22 ?
      "#{resident_name_helper(object.name)}'s #{object.age.ordinalize} Birthday!"
      :
      "#{resident_name_helper(object.name)}'s Birthday!"
  end

  def description
    object.age < 22 ?
      "#{resident_name_helper(object.name)}'s #{object.age.ordinalize} Birthday!"
      :
      "#{resident_name_helper(object.name)}'s Birthday!"
  end

  def start
    Date.new(Date.today.year, object.birthday.month, object.birthday.day)
  end
end
