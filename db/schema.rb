# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2020_04_18_183434) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "admin_users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.bigint "community_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "superuser", default: false, null: false
    t.index ["community_id"], name: "index_admin_users_on_community_id"
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "audits", force: :cascade do |t|
    t.integer "auditable_id"
    t.string "auditable_type"
    t.integer "associated_id"
    t.string "associated_type"
    t.integer "user_id"
    t.string "user_type"
    t.string "username"
    t.string "action"
    t.jsonb "audited_changes"
    t.integer "version", default: 0
    t.string "comment"
    t.string "remote_address"
    t.string "request_uuid"
    t.datetime "created_at"
    t.index ["associated_type", "associated_id"], name: "associated_index"
    t.index ["auditable_type", "auditable_id"], name: "auditable_index"
    t.index ["created_at"], name: "index_audits_on_created_at"
    t.index ["request_uuid"], name: "index_audits_on_request_uuid"
    t.index ["user_id", "user_type"], name: "user_index"
  end

  create_table "bills", force: :cascade do |t|
    t.bigint "meal_id", null: false
    t.bigint "resident_id", null: false
    t.bigint "community_id", null: false
    t.integer "amount_cents", default: 0, null: false
    t.string "amount_currency", default: "USD", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "no_cost", default: false, null: false
    t.index ["community_id"], name: "index_bills_on_community_id"
    t.index ["meal_id", "resident_id"], name: "index_bills_on_meal_id_and_resident_id", unique: true
    t.index ["meal_id"], name: "index_bills_on_meal_id"
    t.index ["resident_id"], name: "index_bills_on_resident_id"
  end

  create_table "common_house_reservations", force: :cascade do |t|
    t.bigint "community_id", null: false
    t.bigint "resident_id", null: false
    t.datetime "start_date", null: false
    t.datetime "end_date", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "title"
    t.index ["community_id"], name: "index_common_house_reservations_on_community_id"
    t.index ["resident_id"], name: "index_common_house_reservations_on_resident_id"
  end

  create_table "communities", force: :cascade do |t|
    t.string "name", null: false
    t.integer "cap"
    t.string "slug", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "timezone", default: "America/Los_Angeles", null: false
    t.index ["name"], name: "index_communities_on_name", unique: true
    t.index ["slug"], name: "index_communities_on_slug", unique: true
  end

  create_table "events", force: :cascade do |t|
    t.string "title", null: false
    t.string "description", default: "", null: false
    t.datetime "start_date", null: false
    t.datetime "end_date"
    t.boolean "allday", default: false, null: false
    t.bigint "community_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["community_id"], name: "index_events_on_community_id"
  end

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string "slug", null: false
    t.integer "sluggable_id", null: false
    t.string "sluggable_type", limit: 50
    t.string "scope"
    t.datetime "created_at"
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
    t.index ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id"
    t.index ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type"
  end

  create_table "guest_room_reservations", force: :cascade do |t|
    t.bigint "community_id", null: false
    t.bigint "resident_id", null: false
    t.date "date", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["community_id"], name: "index_guest_room_reservations_on_community_id"
    t.index ["resident_id"], name: "index_guest_room_reservations_on_resident_id"
  end

  create_table "guests", force: :cascade do |t|
    t.bigint "meal_id", null: false
    t.bigint "resident_id", null: false
    t.integer "multiplier", default: 2, null: false
    t.string "name", default: "", null: false
    t.boolean "vegetarian", default: false, null: false
    t.boolean "late", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["meal_id"], name: "index_guests_on_meal_id"
    t.index ["resident_id"], name: "index_guests_on_resident_id"
  end

  create_table "keys", force: :cascade do |t|
    t.string "token", null: false
    t.string "identity_type", null: false
    t.bigint "identity_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["identity_type", "identity_id"], name: "index_keys_on_identity_type_and_identity_id", unique: true
    t.index ["token"], name: "index_keys_on_token", unique: true
  end

  create_table "meal_residents", force: :cascade do |t|
    t.bigint "meal_id", null: false
    t.bigint "resident_id", null: false
    t.bigint "community_id", null: false
    t.integer "multiplier", null: false
    t.boolean "vegetarian", default: false, null: false
    t.boolean "late", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["community_id"], name: "index_meal_residents_on_community_id"
    t.index ["meal_id", "resident_id"], name: "index_meal_residents_on_meal_id_and_resident_id", unique: true
    t.index ["meal_id"], name: "index_meal_residents_on_meal_id"
    t.index ["resident_id"], name: "index_meal_residents_on_resident_id"
  end

  create_table "meals", force: :cascade do |t|
    t.date "date", null: false
    t.integer "cap"
    t.integer "meal_residents_count", default: 0, null: false
    t.integer "guests_count", default: 0, null: false
    t.integer "bills_count", default: 0, null: false
    t.integer "cost", default: 0, null: false
    t.integer "meal_residents_multiplier", default: 0, null: false
    t.integer "guests_multiplier", default: 0, null: false
    t.text "description", default: "", null: false
    t.integer "max"
    t.boolean "closed", default: false, null: false
    t.bigint "community_id", null: false
    t.bigint "reconciliation_id"
    t.bigint "rotation_id"
    t.datetime "closed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "start_time", null: false
    t.index ["community_id"], name: "index_meals_on_community_id"
    t.index ["date", "community_id"], name: "index_meals_on_date_and_community_id", unique: true
    t.index ["reconciliation_id"], name: "index_meals_on_reconciliation_id"
    t.index ["rotation_id"], name: "index_meals_on_rotation_id"
  end

  create_table "reconciliations", force: :cascade do |t|
    t.date "date", null: false
    t.bigint "community_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["community_id"], name: "index_reconciliations_on_community_id"
  end

  create_table "resident_balances", force: :cascade do |t|
    t.bigint "resident_id", null: false
    t.integer "amount", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["resident_id"], name: "index_resident_balances_on_resident_id"
  end

  create_table "residents", force: :cascade do |t|
    t.string "name", null: false
    t.string "email"
    t.bigint "community_id", null: false
    t.bigint "unit_id", null: false
    t.boolean "vegetarian", default: false, null: false
    t.integer "bill_costs", default: 0, null: false
    t.integer "bills_count", default: 0, null: false
    t.integer "multiplier", default: 2, null: false
    t.string "password_digest", null: false
    t.string "reset_password_token"
    t.boolean "balance_is_dirty", default: true, null: false
    t.boolean "can_cook", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "active", default: true, null: false
    t.date "birthday", default: "1900-01-01", null: false
    t.index ["community_id"], name: "index_residents_on_community_id"
    t.index ["email"], name: "index_residents_on_email", unique: true
    t.index ["name", "community_id"], name: "index_residents_on_name_and_community_id", unique: true
    t.index ["reset_password_token"], name: "index_residents_on_reset_password_token", unique: true
    t.index ["unit_id"], name: "index_residents_on_unit_id"
  end

  create_table "rotations", force: :cascade do |t|
    t.bigint "community_id", null: false
    t.string "description", default: "", null: false
    t.string "color", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "residents_notified", default: false, null: false
    t.date "start_date"
    t.integer "place_value"
    t.index ["community_id"], name: "index_rotations_on_community_id"
  end

  create_table "units", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "community_id", null: false
    t.integer "residents_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["community_id", "name"], name: "index_units_on_community_id_and_name", unique: true
    t.index ["community_id"], name: "index_units_on_community_id"
  end

  add_foreign_key "admin_users", "communities"
  add_foreign_key "bills", "communities"
  add_foreign_key "bills", "meals"
  add_foreign_key "bills", "residents"
  add_foreign_key "common_house_reservations", "communities"
  add_foreign_key "common_house_reservations", "residents"
  add_foreign_key "events", "communities"
  add_foreign_key "guest_room_reservations", "communities"
  add_foreign_key "guest_room_reservations", "residents"
  add_foreign_key "guests", "meals"
  add_foreign_key "guests", "residents"
  add_foreign_key "meal_residents", "communities"
  add_foreign_key "meal_residents", "meals"
  add_foreign_key "meal_residents", "residents"
  add_foreign_key "meals", "communities"
  add_foreign_key "meals", "reconciliations"
  add_foreign_key "meals", "rotations"
  add_foreign_key "reconciliations", "communities"
  add_foreign_key "resident_balances", "residents"
  add_foreign_key "residents", "communities"
  add_foreign_key "residents", "units"
  add_foreign_key "rotations", "communities"
  add_foreign_key "units", "communities"
end
