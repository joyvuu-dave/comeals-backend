# frozen_string_literal: true

class ConvertFinancialColumnsToDecimal < ActiveRecord::Migration[7.0]
  def up
    # Bills: convert amount_cents (integer cents) to amount (decimal dollars).
    # Use USING clause so the division happens atomically with the type change —
    # without it, cent values (e.g. 18274) overflow DECIMAL(12,8)'s 4-digit
    # integer part before the UPDATE can divide them down to dollars.
    execute <<~SQL.squish
      ALTER TABLE bills
        ALTER COLUMN amount_cents TYPE decimal(12, 8) USING amount_cents / 100.0,
        ALTER COLUMN amount_cents SET DEFAULT 0
    SQL
    rename_column :bills, :amount_cents, :amount
    remove_column :bills, :amount_currency

    # meals.cost is NOT converted. It's a counter_culture cache with known
    # drift (including a corrupt -620200 value) and gets dropped entirely in
    # RemoveCostColumnFromMeals. No code reads it.

    # Meals: convert cap (integer cents) to decimal dollars
    # NULL means "no cap" — preserve that semantics
    execute <<~SQL.squish
      ALTER TABLE meals
        ALTER COLUMN cap TYPE decimal(12, 8) USING cap / 100.0
    SQL

    # Communities: convert cap (integer cents) to decimal dollars
    execute <<~SQL.squish
      ALTER TABLE communities
        ALTER COLUMN cap TYPE decimal(12, 8) USING cap / 100.0
    SQL

    # Resident balances: convert amount (integer cents) to decimal dollars
    execute <<~SQL.squish
      ALTER TABLE resident_balances
        ALTER COLUMN amount TYPE decimal(12, 8) USING amount / 100.0,
        ALTER COLUMN amount SET DEFAULT 0
    SQL
  end

  def down
    # Resident balances: convert back to integer cents
    execute 'UPDATE resident_balances SET amount = (amount * 100)'
    change_column :resident_balances, :amount, :integer, default: 0, null: false

    # Communities: convert cap back to integer cents
    execute 'UPDATE communities SET cap = (cap * 100) WHERE cap IS NOT NULL'
    change_column :communities, :cap, :integer, null: true

    # Meals: convert cap back to integer cents
    execute 'UPDATE meals SET cap = (cap * 100) WHERE cap IS NOT NULL'
    change_column :meals, :cap, :integer, null: true

    # Bills: convert amount back to amount_cents integer
    rename_column :bills, :amount, :amount_cents
    execute 'UPDATE bills SET amount_cents = (amount_cents * 100)'
    change_column :bills, :amount_cents, :integer, default: 0, null: false
    add_column :bills, :amount_currency, :string, default: 'USD', null: false
  end
end
