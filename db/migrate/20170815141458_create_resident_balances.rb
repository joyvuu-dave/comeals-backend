class CreateResidentBalances < ActiveRecord::Migration[5.1]
  def change
    create_table :resident_balances do |t|
      t.references :resident, foreign_key: true, null: false
      t.integer :amount, null: false, default: 0

      t.timestamps
    end
  end
end
