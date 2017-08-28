class CreateRotations < ActiveRecord::Migration[5.1]
  def change
    create_table :rotations do |t|
      t.references :community, foreign_key: true, null: false
      t.string :description, null: false
      t.string :color, null: false

      t.timestamps
    end
  end
end
