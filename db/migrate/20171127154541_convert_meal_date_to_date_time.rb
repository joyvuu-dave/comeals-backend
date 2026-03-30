# frozen_string_literal: true

class ConvertMealDateToDateTime < ActiveRecord::Migration[5.1]
  def up
    add_column :meals, :start_time, :datetime

    Meal.find_each do |meal|
      date = meal.date
      zone = meal.community.timezone

      Time.use_zone(zone) do
        time = date.at_beginning_of_day + 19.hours
        time -= 1.hour if date.wday.zero?

        meal.start_time = time
        meal.save!
      end
    end

    change_column_null :meals, :start_time, false
  end

  def down
    remove_column :meals, :start_time
  end
end
