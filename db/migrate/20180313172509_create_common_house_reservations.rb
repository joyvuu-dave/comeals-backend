class CreateCommonHouseReservations < ActiveRecord::Migration[5.1]
  def change
    create_table :common_house_reservations do |t|
      t.references :community, foreign_key: true, null: false
      t.references :resident, foreign_key: true, null: false
      t.datetime :start_date, null: false
      t.datetime :end_date, null: false

      t.timestamps
    end
  end
end
