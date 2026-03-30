# frozen_string_literal: true

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
    'Birthday'
  end

  def title
    if object.age < 22
      "#{resident_name_helper(object.name)}'s #{object.age.ordinalize} B-day!"
    else
      "#{resident_name_helper(object.name)}'s B-day!"
    end
  end

  def description
    if object.age < 22
      "#{resident_name_helper(object.name)}'s #{object.age.ordinalize} Birthday!"
    else
      "#{resident_name_helper(object.name)}'s Birthday!"
    end
  end

  def start
    Date.new(Time.zone.today.year, (object.birthday + 1.day).month, (object.birthday + 1.day).day)
  end

  def end
    Date.new(Time.zone.today.year, (object.birthday + 1.day).month, (object.birthday + 1.day).day)
  end

  def color
    '#7335bc'
  end
end
