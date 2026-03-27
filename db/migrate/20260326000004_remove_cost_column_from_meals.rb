class RemoveCostColumnFromMeals < ActiveRecord::Migration[7.0]
  def up
    remove_column :meals, :cost
  end

  def down
    add_column :meals, :cost, :decimal, precision: 12, scale: 8, default: 0, null: false
  end
end
