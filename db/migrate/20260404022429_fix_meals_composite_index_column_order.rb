# frozen_string_literal: true

# Fix composite index column order on meals.
#
# B-tree composite indexes are most efficient when equality columns precede
# range columns. Every meals query filters WHERE community_id = ? AND date
# BETWEEN ? AND ?, so (community_id, date) is optimal — not (date, community_id).
#
# This also makes the standalone index_meals_on_community_id redundant,
# since a composite B-tree index covers leading-column queries.
class FixMealsCompositeIndexColumnOrder < ActiveRecord::Migration[8.1]
  def up
    # Replace (date, community_id) with (community_id, date) — equality first, range second
    remove_index :meals, %i[date community_id]
    add_index :meals, %i[community_id date], unique: true, name: :index_meals_on_community_id_and_date

    # The standalone community_id index is now redundant (covered by the composite)
    remove_index :meals, :community_id
  end

  def down
    add_index :meals, :community_id, name: :index_meals_on_community_id
    remove_index :meals, %i[community_id date]
    add_index :meals, %i[date community_id], unique: true, name: :index_meals_on_date_and_community_id
  end
end
