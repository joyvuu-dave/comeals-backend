class AddActiveToResidents < ActiveRecord::Migration[5.1]
  def change
    add_column :residents, :active, :boolean, null: false, default: true
  end
end
