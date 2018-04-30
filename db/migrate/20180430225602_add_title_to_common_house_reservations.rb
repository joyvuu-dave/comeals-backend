class AddTitleToCommonHouseReservations < ActiveRecord::Migration[5.2]
  def change
    add_column :common_house_reservations, :title, :string
  end
end
