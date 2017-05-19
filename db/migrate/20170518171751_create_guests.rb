class CreateGuests < ActiveRecord::Migration[5.1]
  def change
    create_table :guests do |t|
      t.references :meal, foreign_key: true, null: false
      t.references :resident, foreign_key: true, null: false
      t.integer :multiplier, null: false, default: 2
      t.string :name, null: false
      t.boolean :vegetarian, null: false, default: false
      t.boolean :late, null: false, default: false

      t.timestamps
    end

  end
end
