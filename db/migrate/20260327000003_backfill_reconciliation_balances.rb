# frozen_string_literal: true

class BackfillReconciliationBalances < ActiveRecord::Migration[7.0]
  def up
    # For each existing reconciliation, compute and persist settlement balances.
    # Uses the Reconciliation model's persist_balances! method which calls
    # settlement_balances (banker's rounding) and writes to reconciliation_balances.
    Reconciliation.find_each(&:persist_balances!)
  end

  def down
    execute 'DELETE FROM reconciliation_balances'
  end
end
