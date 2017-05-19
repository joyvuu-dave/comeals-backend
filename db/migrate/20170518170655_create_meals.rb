class CreateMeals < ActiveRecord::Migration[5.1]
  def change
    create_table :meals do |t|
      t.date :date, null: false
      t.integer :cap
      t.integer :meal_residents_count, null: false, default: 0
      t.integer :guests_count, null: false, default: 0
      t.integer :bills_count, null: false, default: 0
      t.integer :cost, null: false, default: 0
      t.integer :meal_residents_multiplier, null: false, default: 0
      t.integer :guests_multiplier, null: false, default: 0
      t.text :description
      t.integer :max
      t.references :community, foreign_key: true, null: false
      t.references :reconciliation, foreign_key: true

      t.timestamps
    end

  end
end
