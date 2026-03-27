class RemoveFinancialCounterCacheColumns < ActiveRecord::Migration[7.0]
  def up
    remove_column :residents, :bill_costs
    remove_column :residents, :balance_is_dirty
  end

  def down
    add_column :residents, :bill_costs, :integer, default: 0, null: false
    add_column :residents, :balance_is_dirty, :boolean, default: true, null: false
  end
end
