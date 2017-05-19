class CreateBills < ActiveRecord::Migration[5.1]
  def change
    create_table :bills do |t|
      t.references :meal, foreign_key: true, null: false
      t.references :resident, foreign_key: true, null: false
      t.references :community, foreign_key: true, null: false
      t.integer :amount_cents, null: false, default: 0
      t.string :amount_currency, null: false, default: "USD"

      t.timestamps
    end

  end
end
