class CreateCommunityAdminUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :community_admin_users do |t|
      t.references :community, foreign_key: true
      t.references :admin_user, foreign_key: true

      t.timestamps
    end
  end
end
