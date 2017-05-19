class CreateReconciliations < ActiveRecord::Migration[5.1]
  def change
    create_table :reconciliations do |t|
      t.date :date, null: false
      t.references :community, foreign_key: true, null: false

      t.timestamps
    end

  end
end
