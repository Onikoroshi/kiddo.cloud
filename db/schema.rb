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

ActiveRecord::Schema.define(version: 20170703223151) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "center_id"
    t.string "last_registration_step_completed"
    t.string "signature"
    t.string "family_physician"
    t.string "physician_phone"
    t.string "family_dentist"
    t.string "dentist_phone"
    t.string "insurance_company"
    t.string "insurance_policy_number"
    t.boolean "waiver_agreement", default: false
    t.boolean "mail_agreements", default: true
    t.boolean "medical_waiver_agreement", default: false
    t.boolean "signup_complete", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["center_id"], name: "index_accounts_on_center_id"
    t.index ["user_id"], name: "index_accounts_on_user_id"
  end

  create_table "addresses", id: :serial, force: :cascade do |t|
    t.string "street"
    t.string "extended"
    t.string "locality"
    t.string "region"
    t.string "postal_code"
    t.string "country_code_alpha3"
    t.string "phone"
    t.string "url"
    t.float "longitude"
    t.float "latitude"
    t.string "addressable_type"
    t.integer "addressable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["addressable_id", "addressable_type"], name: "index_addresses_on_addressable_id_and_addressable_type", unique: true
    t.index ["addressable_type", "addressable_id"], name: "index_addresses_on_addressable_type_and_addressable_id"
  end

  create_table "care_items", force: :cascade do |t|
    t.bigint "child_id"
    t.string "name"
    t.boolean "active"
    t.text "explanation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["child_id"], name: "index_care_items_on_child_id"
  end

  create_table "centers", force: :cascade do |t|
    t.string "name"
    t.string "subdomain"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "child_locations", force: :cascade do |t|
    t.bigint "child_id"
    t.bigint "location_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["child_id"], name: "index_child_locations_on_child_id"
    t.index ["location_id"], name: "index_child_locations_on_location_id"
  end

  create_table "children", force: :cascade do |t|
    t.bigint "account_id"
    t.bigint "parent_id"
    t.string "first_name"
    t.string "last_name"
    t.string "grade_entering"
    t.date "birthdate"
    t.text "additional_info"
    t.string "gender"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_children_on_account_id"
    t.index ["parent_id"], name: "index_children_on_parent_id"
  end

  create_table "children_parents", id: false, force: :cascade do |t|
    t.bigint "parent_id", null: false
    t.bigint "child_id", null: false
    t.index ["child_id", "parent_id"], name: "index_children_parents_on_child_id_and_parent_id"
    t.index ["parent_id", "child_id"], name: "index_children_parents_on_parent_id_and_child_id"
  end

  create_table "emergency_contacts", force: :cascade do |t|
    t.bigint "account_id"
    t.string "first_name"
    t.string "last_name"
    t.string "phone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_emergency_contacts_on_account_id"
  end

  create_table "locations", force: :cascade do |t|
    t.bigint "center_id"
    t.string "name"
    t.boolean "default", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["center_id"], name: "index_locations_on_center_id"
  end

  create_table "parents", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "account_id"
    t.string "first_name"
    t.string "last_name"
    t.string "phone"
    t.boolean "primary", default: false
    t.boolean "secondary", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_parents_on_account_id"
    t.index ["user_id"], name: "index_parents_on_user_id"
  end

  create_table "permissions", force: :cascade do |t|
    t.string "name"
    t.string "slug"
    t.string "display_name"
    t.string "short_description"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "roles", force: :cascade do |t|
    t.string "name"
    t.string "slug"
    t.string "display_name"
    t.string "short_description"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "staffs", force: :cascade do |t|
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_staffs_on_user_id"
  end

  create_table "time_disputes", force: :cascade do |t|
    t.bigint "location_id"
    t.bigint "created_by_id"
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.string "phone"
    t.date "date"
    t.text "message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_time_disputes_on_created_by_id"
    t.index ["location_id"], name: "index_time_disputes_on_location_id"
  end

  create_table "time_entries", force: :cascade do |t|
    t.bigint "location_id"
    t.datetime "time"
    t.string "record_type"
    t.string "time_recordable_type"
    t.bigint "time_recordable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["location_id"], name: "index_time_entries_on_location_id"
    t.index ["time_recordable_type", "time_recordable_id"], name: "index_recordable_id_type"
  end

  create_table "user_permissions", id: :serial, force: :cascade do |t|
    t.integer "permission_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["permission_id"], name: "index_user_permissions_on_permission_id"
    t.index ["user_id"], name: "index_user_permissions_on_user_id"
  end

  create_table "user_roles", id: :serial, force: :cascade do |t|
    t.integer "role_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["role_id"], name: "index_user_roles_on_role_id"
    t.index ["user_id"], name: "index_user_roles_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.bigint "center_id"
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
    t.string "first_name"
    t.string "last_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["center_id"], name: "index_users_on_center_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "accounts", "centers"
  add_foreign_key "accounts", "users"
  add_foreign_key "care_items", "children"
  add_foreign_key "emergency_contacts", "accounts"
  add_foreign_key "time_disputes", "locations"
end
