class AddPlaceValueToRotations < ActiveRecord::Migration[5.2]
  def change
  	add_column :rotations, :place_value, :integer

    Rotation.order('start_date ASC').pluck(:id).each_with_index do |id, index|
    	Rotation.find(id).update_columns(place_value: index + 1)
    end
	end
end
