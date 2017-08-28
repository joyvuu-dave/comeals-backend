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
      t.text :description, null: false, default: ""
      t.integer :max
      t.boolean :closed, null: false, default: false
      t.references :community, foreign_key: true, null: false
      t.references :reconciliation, foreign_key: true
      t.references :rotation, foreign_key: true
      t.datetime :closed_at

      t.timestamps
    end

  end
end
