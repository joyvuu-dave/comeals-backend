class RemoveCounterCultureColumns < ActiveRecord::Migration[7.0]
  def up
    remove_column :meals, :bills_count
    remove_column :meals, :meal_residents_count
    remove_column :meals, :guests_count
    remove_column :meals, :meal_residents_multiplier
    remove_column :meals, :guests_multiplier
    remove_column :residents, :bills_count
    remove_column :units, :residents_count
  end

  def down
    add_column :meals, :bills_count, :integer, default: 0, null: false
    add_column :meals, :meal_residents_count, :integer, default: 0, null: false
    add_column :meals, :guests_count, :integer, default: 0, null: false
    add_column :meals, :meal_residents_multiplier, :integer, default: 0, null: false
    add_column :meals, :guests_multiplier, :integer, default: 0, null: false
    add_column :residents, :bills_count, :integer, default: 0, null: false
    add_column :units, :residents_count, :integer, default: 0, null: false
  end
end
