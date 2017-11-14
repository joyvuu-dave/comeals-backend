class AddBirthdayToResidents < ActiveRecord::Migration[5.1]
  def change
    add_column :residents, :birthday, :date, null: false, default: Date.new(1900, 1, 1)
  end
end
