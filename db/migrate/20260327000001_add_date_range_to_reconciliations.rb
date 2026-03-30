# frozen_string_literal: true

class AddDateRangeToReconciliations < ActiveRecord::Migration[7.0]
  def up
    add_column :reconciliations, :start_date, :date
    add_column :reconciliations, :end_date, :date

    # Backfill from actual meal dates for existing reconciliations
    execute <<~SQL.squish
      UPDATE reconciliations
      SET start_date = sub.min_date,
          end_date = sub.max_date
      FROM (
        SELECT reconciliation_id,
               MIN(date) AS min_date,
               MAX(date) AS max_date
        FROM meals
        WHERE reconciliation_id IS NOT NULL
        GROUP BY reconciliation_id
      ) sub
      WHERE reconciliations.id = sub.reconciliation_id
    SQL

    # Fallback for any reconciliation with no meals
    execute <<~SQL.squish
      UPDATE reconciliations
      SET start_date = date, end_date = date
      WHERE start_date IS NULL
    SQL

    change_column_null :reconciliations, :start_date, false
    change_column_null :reconciliations, :end_date, false

    execute <<~SQL.squish
      ALTER TABLE reconciliations
        ADD CONSTRAINT reconciliations_date_range_valid CHECK (start_date <= end_date)
    SQL
  end

  def down
    execute <<~SQL.squish
      ALTER TABLE reconciliations
        DROP CONSTRAINT reconciliations_date_range_valid
    SQL

    remove_column :reconciliations, :start_date
    remove_column :reconciliations, :end_date
  end
end
