class AddTimezoneToCommunities < ActiveRecord::Migration[5.1]
  def up
    add_column :communities, :timezone, :string, null: false, default: "America/Los_Angeles"
  end

  def down
    remove_column :communities, :timezone
  end
end
