class ConvertFinancialColumnsToDecimal < ActiveRecord::Migration[7.0]
  def up
    # Bills: convert amount_cents (integer cents) to amount (decimal dollars)
    change_column :bills, :amount_cents, :decimal, precision: 12, scale: 8, default: 0, null: false
    execute "UPDATE bills SET amount_cents = amount_cents / 100::numeric"
    rename_column :bills, :amount_cents, :amount
    remove_column :bills, :amount_currency

    # Meals: convert cost (integer cents) to decimal dollars
    change_column :meals, :cost, :decimal, precision: 12, scale: 8, default: 0, null: false
    execute "UPDATE meals SET cost = cost / 100::numeric"

    # Meals: convert cap (integer cents) to decimal dollars
    # NULL means "no cap" — we preserve that semantics
    change_column :meals, :cap, :decimal, precision: 12, scale: 8, null: true
    execute "UPDATE meals SET cap = cap / 100::numeric WHERE cap IS NOT NULL"

    # Communities: convert cap (integer cents) to decimal dollars
    change_column :communities, :cap, :decimal, precision: 12, scale: 8, null: true
    execute "UPDATE communities SET cap = cap / 100::numeric WHERE cap IS NOT NULL"

    # Resident balances: convert amount (integer cents) to decimal dollars
    change_column :resident_balances, :amount, :decimal, precision: 12, scale: 8, default: 0, null: false
    execute "UPDATE resident_balances SET amount = amount / 100::numeric"
  end

  def down
    # Resident balances: convert back to integer cents
    execute "UPDATE resident_balances SET amount = (amount * 100)::integer"
    change_column :resident_balances, :amount, :integer, default: 0, null: false

    # Communities: convert cap back to integer cents
    execute "UPDATE communities SET cap = (cap * 100)::integer WHERE cap IS NOT NULL"
    change_column :communities, :cap, :integer, null: true

    # Meals: convert cap back to integer cents
    execute "UPDATE meals SET cap = (cap * 100)::integer WHERE cap IS NOT NULL"
    change_column :meals, :cap, :integer, null: true

    # Meals: convert cost back to integer cents
    execute "UPDATE meals SET cost = (cost * 100)::integer"
    change_column :meals, :cost, :integer, default: 0, null: false

    # Bills: convert amount back to amount_cents integer
    rename_column :bills, :amount, :amount_cents
    execute "UPDATE bills SET amount_cents = (amount_cents * 100)::integer"
    change_column :bills, :amount_cents, :integer, default: 0, null: false
    add_column :bills, :amount_currency, :string, default: "USD", null: false
  end
end
