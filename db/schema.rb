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

ActiveRecord::Schema.define(version: 20170529182616) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

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

  create_table "centers", force: :cascade do |t|
    t.string "name"
    t.string "subdomain"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "children", force: :cascade do |t|
    t.bigint "parent_id"
    t.string "first_name"
    t.string "last_name"
    t.string "grade_entering"
    t.date "birthdate"
    t.text "additional_info"
    t.string "gender"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["parent_id"], name: "index_children_on_parent_id"
  end

  create_table "children_parents", id: false, force: :cascade do |t|
    t.bigint "parent_id", null: false
    t.bigint "child_id", null: false
    t.index ["child_id", "parent_id"], name: "index_children_parents_on_child_id_and_parent_id"
    t.index ["parent_id", "child_id"], name: "index_children_parents_on_parent_id_and_child_id"
  end

  create_table "cores", force: :cascade do |t|
    t.bigint "center_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["center_id"], name: "index_cores_on_center_id"
  end

  create_table "emergency_contacts", force: :cascade do |t|
    t.bigint "core_id"
    t.string "first_name"
    t.string "last_name"
    t.string "phone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["core_id"], name: "index_emergency_contacts_on_core_id"
  end

  create_table "locations", force: :cascade do |t|
    t.bigint "center_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["center_id"], name: "index_locations_on_center_id"
  end

  create_table "parents", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "core_id"
    t.boolean "primary", default: false
    t.string "phone"
    t.string "email"
    t.string "signature"
    t.boolean "agreed_to_waivers"
    t.boolean "email_waivers"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["core_id"], name: "index_parents_on_core_id"
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

  add_foreign_key "cores", "centers"
  add_foreign_key "emergency_contacts", "cores"
end
