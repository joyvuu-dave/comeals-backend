class CreateGuestRoomReservations < ActiveRecord::Migration[5.1]
  def change
    create_table :guest_room_reservations do |t|
      t.references :community, foreign_key: true, null: false
      t.references :resident, foreign_key: true, null: false
      t.date :date, null: false

      t.timestamps
    end
  end
end
