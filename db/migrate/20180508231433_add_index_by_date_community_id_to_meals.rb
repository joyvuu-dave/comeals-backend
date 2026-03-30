# frozen_string_literal: true

class AddIndexByDateCommunityIdToMeals < ActiveRecord::Migration[5.2]
  def change
    add_index :meals, %i[date community_id], unique: true
  end
end
