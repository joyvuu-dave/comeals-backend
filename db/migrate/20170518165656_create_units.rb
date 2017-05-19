class CreateUnits < ActiveRecord::Migration[5.1]
  def change
    create_table :units do |t|
      t.string :name, null: false
      t.references :community, foreign_key: true, null: false

      t.timestamps
    end

    add_index :units, [:community_id, :name], unique: true
  end
end
