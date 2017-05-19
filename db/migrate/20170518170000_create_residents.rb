class CreateResidents < ActiveRecord::Migration[5.1]
  def change
    create_table :residents do |t|
      t.string :name, null: false
      t.references :community, foreign_key: true, null: false
      t.references :unit, foreign_key: true, null: false
      t.boolean :vegetarian, null: false, default: false
      t.integer :bill_costs, null: false, default: 0
      t.integer :bills_count, null: false, default: 0
      t.integer :multiplier, null: false, default: 2
      t.string :password_digest, null: false

      t.timestamps
    end

    add_index :residents, [:name, :community_id], unique: true
  end
end
