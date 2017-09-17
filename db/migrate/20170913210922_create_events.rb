class CreateEvents < ActiveRecord::Migration[5.1]
  def change
    create_table :events do |t|
      t.string :title, null: false
      t.string :description, null: false, default: ""
      t.datetime :start_date, null: false
      t.datetime :end_date
      t.boolean :allday, null: false, default: false
      t.references :community, foreign_key: true, null: false

      t.timestamps
    end
  end
end
