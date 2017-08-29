class CreateResidents < ActiveRecord::Migration[5.1]
  def change
    create_table :residents do |t|
      t.string :name, null: false
      t.string :email
      t.references :community, foreign_key: true, null: false
      t.references :unit, foreign_key: true, null: false
      t.boolean :vegetarian, null: false, default: false
      t.integer :bill_costs, null: false, default: 0
      t.integer :bills_count, null: false, default: 0
      t.integer :multiplier, null: false, default: 2
      t.string :password_digest, null: false
      t.string :reset_password_token
      t.boolean :balance_is_dirty, null: false, default: true
      t.boolean :can_cook, null: false, default: true

      t.timestamps
    end

    add_index :residents, [:name, :community_id], unique: true
    add_index :residents, :email, unique: true
    add_index :residents, :reset_password_token, unique: true
  end
end
