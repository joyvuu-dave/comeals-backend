class CreateCommunityManagers < ActiveRecord::Migration[5.1]
  def change
    create_table :community_managers do |t|
      t.references :community, foreign_key: true
      t.references :manager, foreign_key: true

      t.timestamps
    end
  end
end
