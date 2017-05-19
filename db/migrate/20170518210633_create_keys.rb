class CreateKeys < ActiveRecord::Migration[5.1]
  def up
    create_table :keys do |t|
      t.string :token, null: false
      t.references :identity, polymorphic: true

      t.timestamps
    end
    add_index :keys, :token, unique: true
    remove_index :keys, name: 'index_keys_on_identity_type_and_identity_id'
    add_index :keys, [:identity_type, :identity_id], unique: true
    change_column_null :keys, :identity_type, false
    change_column_null :keys, :identity_id, false
  end

  def down
    drop_table :keys
  end
end
