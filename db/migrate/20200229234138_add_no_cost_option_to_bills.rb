class AddNoCostOptionToBills < ActiveRecord::Migration[5.2]
  def change
    add_column :bills, :no_cost, :boolean, null: false, default: false
  end
end
