class AddStartDateToRotation < ActiveRecord::Migration[5.1]
  def change
    add_column :rotations, :start_date, :date
  end
end
