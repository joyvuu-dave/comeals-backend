class AddIndexByDateCommunityIdToMeals < ActiveRecord::Migration[5.2]
  def change
    add_index :meals, [:date, :community_id], unique: true
  end
end
