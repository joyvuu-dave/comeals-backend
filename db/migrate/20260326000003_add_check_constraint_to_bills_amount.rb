class AddCheckConstraintToBillsAmount < ActiveRecord::Migration[7.0]
  def up
    execute "ALTER TABLE bills ADD CONSTRAINT bills_amount_non_negative CHECK (amount >= 0)"
  end

  def down
    execute "ALTER TABLE bills DROP CONSTRAINT bills_amount_non_negative"
  end
end
