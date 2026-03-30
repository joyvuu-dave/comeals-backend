# frozen_string_literal: true

class AddStartDateToRotation < ActiveRecord::Migration[5.1]
  def up
    add_column :rotations, :start_date, :date

    Rotation.find_each(&:set_start_date)
  end

  def down
    remove_column :rotations, :start_date
  end
end
