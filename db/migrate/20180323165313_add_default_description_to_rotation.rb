class AddDefaultDescriptionToRotation < ActiveRecord::Migration[5.1]
  def change
    change_column_default(:rotations, :description, "")
  end
end
