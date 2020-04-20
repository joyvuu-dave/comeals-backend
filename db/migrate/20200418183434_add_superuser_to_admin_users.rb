class AddSuperuserToAdminUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :admin_users, :superuser, :boolean, null: false, default: false
  end
end
