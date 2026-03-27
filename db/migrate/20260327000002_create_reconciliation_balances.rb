class CreateReconciliationBalances < ActiveRecord::Migration[7.0]
  def change
    create_table :reconciliation_balances do |t|
      t.references :reconciliation, null: false, foreign_key: true
      t.references :resident, null: false, foreign_key: true
      t.decimal :amount, precision: 12, scale: 8, null: false, default: 0

      t.timestamps
    end

    add_index :reconciliation_balances, [:reconciliation_id, :resident_id],
              unique: true, name: "index_recon_balances_on_recon_id_and_resident_id"
  end
end
