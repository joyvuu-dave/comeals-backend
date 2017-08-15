class AddBalanceIsDirty < ActiveRecord::Migration[5.1]
  def change
    add_column :residents, :balance_is_dirty, :boolean, null: false, default: true
  end
end
