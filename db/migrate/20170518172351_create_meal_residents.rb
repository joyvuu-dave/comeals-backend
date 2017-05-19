class CreateMealResidents < ActiveRecord::Migration[5.1]
  def change
    create_table :meal_residents do |t|
      t.references :meal, foreign_key: true, null: false
      t.references :resident, foreign_key: true, null: false
      t.references :community, foreign_key: true, null: false
      t.integer :multiplier, null: false
      t.boolean :vegetarian, null: false, default: false
      t.boolean :late, null: false, default: false

      t.timestamps
    end

    add_index :meal_residents, [:meal_id, :resident_id], unique: true
  end
end
