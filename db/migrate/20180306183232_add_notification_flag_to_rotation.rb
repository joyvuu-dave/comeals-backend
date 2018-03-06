class AddNotificationFlagToRotation < ActiveRecord::Migration[5.1]
  def change
    add_column :rotations, :residents_notified, :boolean, null: false, default: false
  end
end
