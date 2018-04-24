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

ActiveRecord::Schema.define(version: 20180422000036) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

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
    t.string "gateway_customer_id"
    t.string "card_brand"
    t.string "card_exp_month"
    t.string "card_exp_year"
    t.string "card_last4"
    t.boolean "waiver_agreement", default: false
    t.boolean "mail_agreements", default: true
    t.boolean "medical_waiver_agreement", default: false
    t.boolean "signup_complete", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "location_id"
    t.bigint "program_id"
    t.integer "payment_offset", default: 0
    t.index ["center_id"], name: "index_accounts_on_center_id"
    t.index ["program_id"], name: "index_accounts_on_program_id"
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

  create_table "attendance_selections", force: :cascade do |t|
    t.bigint "child_id"
    t.boolean "monday"
    t.boolean "tuesday"
    t.boolean "wednesday"
    t.boolean "thursday"
    t.boolean "friday"
    t.boolean "saturday"
    t.boolean "sunday"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["child_id"], name: "index_attendance_selections_on_child_id"
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
    t.string "first_name"
    t.string "last_name"
    t.string "grade_entering"
    t.date "birthdate"
    t.text "additional_info"
    t.string "gender"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_children_on_account_id"
  end

  create_table "children_parents", id: false, force: :cascade do |t|
    t.bigint "parent_id", null: false
    t.bigint "child_id", null: false
    t.index ["child_id", "parent_id"], name: "index_children_parents_on_child_id_and_parent_id"
    t.index ["parent_id", "child_id"], name: "index_children_parents_on_parent_id_and_child_id"
  end

  create_table "discounts", force: :cascade do |t|
    t.bigint "plan_id"
    t.float "amount"
    t.string "month"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["plan_id"], name: "index_discounts_on_plan_id"
  end

  create_table "drop_ins", force: :cascade do |t|
    t.bigint "account_id"
    t.bigint "program_id"
    t.bigint "child_id"
    t.bigint "location_id"
    t.date "date"
    t.text "notes"
    t.float "price"
    t.boolean "paid", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "time_slot"
    t.index ["account_id"], name: "index_drop_ins_on_account_id"
    t.index ["child_id"], name: "index_drop_ins_on_child_id"
    t.index ["location_id"], name: "index_drop_ins_on_location_id"
    t.index ["program_id"], name: "index_drop_ins_on_program_id"
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

  create_table "enrollment_change_transactions", force: :cascade do |t|
    t.bigint "enrollment_change_id"
    t.bigint "my_transaction_id"
    t.float "amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["enrollment_change_id"], name: "index_enrollment_change_transactions_on_enrollment_change_id"
    t.index ["my_transaction_id"], name: "index_enrollment_change_transactions_on_my_transaction_id"
  end

  create_table "enrollment_changes", force: :cascade do |t|
    t.bigint "account_id"
    t.bigint "enrollment_id"
    t.boolean "requires_refund"
    t.boolean "requires_fee"
    t.boolean "applied", default: false
    t.text "description"
    t.float "amount"
    t.jsonb "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_enrollment_changes_on_account_id"
    t.index ["enrollment_id"], name: "index_enrollment_changes_on_enrollment_id"
  end

  create_table "enrollment_transactions", force: :cascade do |t|
    t.bigint "enrollment_id"
    t.bigint "my_transaction_id"
    t.float "amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "target_date"
    t.index ["enrollment_id"], name: "index_enrollment_transactions_on_enrollment_id"
    t.index ["my_transaction_id"], name: "index_enrollment_transactions_on_my_transaction_id"
  end

  create_table "enrollments", force: :cascade do |t|
    t.bigint "child_id"
    t.bigint "plan_id"
    t.bigint "location_id"
    t.boolean "monday", default: false
    t.boolean "tuesday", default: false
    t.boolean "wednesday", default: false
    t.boolean "thursday", default: false
    t.boolean "friday", default: false
    t.boolean "saturday", default: false
    t.boolean "sunday", default: false
    t.boolean "paid", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "sibling_club", default: false
    t.date "starts_at"
    t.date "ends_at"
    t.boolean "dead", default: false
    t.index ["child_id"], name: "index_enrollments_on_child_id"
    t.index ["location_id"], name: "index_enrollments_on_location_id"
    t.index ["plan_id"], name: "index_enrollments_on_plan_id"
  end

  create_table "late_checkin_notifications", force: :cascade do |t|
    t.bigint "account_id"
    t.bigint "child_id"
    t.string "sent_at"
    t.string "sent_to_email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_late_checkin_notifications_on_account_id"
    t.index ["child_id"], name: "index_late_checkin_notifications_on_child_id"
  end

  create_table "legacy_users", force: :cascade do |t|
    t.string "email"
    t.date "paid_through"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "reregistered", default: false
    t.boolean "completed_signed_up", default: false
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

  create_table "plans", force: :cascade do |t|
    t.bigint "program_id"
    t.string "display_name"
    t.integer "days_per_week"
    t.float "price"
    t.string "plan_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "monday", default: false
    t.boolean "tuesday", default: false
    t.boolean "wednesday", default: false
    t.boolean "thursday", default: false
    t.boolean "friday", default: false
    t.boolean "saturday", default: false
    t.boolean "sunday", default: false
    t.index ["program_id"], name: "index_plans_on_program_id"
  end

  create_table "program_locations", force: :cascade do |t|
    t.bigint "program_id"
    t.bigint "location_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["location_id"], name: "index_program_locations_on_location_id"
    t.index ["program_id"], name: "index_program_locations_on_program_id"
  end

  create_table "programs", force: :cascade do |t|
    t.bigint "center_id"
    t.string "name"
    t.date "starts_at"
    t.date "ends_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "registration_opens"
    t.date "registration_closes"
    t.float "registration_fee"
    t.float "change_fee"
    t.integer "earliest_payment_offset", default: -15
    t.integer "latest_payment_offset", default: 15
    t.index ["center_id"], name: "index_programs_on_center_id"
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

  create_table "staff", force: :cascade do |t|
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_staff_on_user_id"
  end

  create_table "staff_locations", force: :cascade do |t|
    t.bigint "staff_id"
    t.bigint "location_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["location_id"], name: "index_staff_locations_on_location_id"
    t.index ["staff_id"], name: "index_staff_locations_on_staff_id"
  end

  create_table "subscriptions", force: :cascade do |t|
    t.bigint "account_id"
    t.string "gateway_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_subscriptions_on_account_id"
  end

  create_table "time_disputes", force: :cascade do |t|
    t.bigint "location_id"
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.string "phone"
    t.date "date"
    t.text "message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
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

  create_table "transactions", force: :cascade do |t|
    t.bigint "account_id"
    t.bigint "program_id"
    t.string "transaction_type"
    t.integer "month"
    t.integer "year"
    t.float "amount"
    t.boolean "paid", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.hstore "itemizations"
    t.bigint "parent_id"
    t.string "gateway_id"
    t.string "receipt_number"
    t.index ["account_id"], name: "index_transactions_on_account_id"
    t.index ["itemizations"], name: "index_transactions_on_itemizations", using: :gin
    t.index ["program_id"], name: "index_transactions_on_program_id"
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
    t.boolean "legacy", default: false
    t.index ["center_id"], name: "index_users_on_center_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "accounts", "centers"
  add_foreign_key "accounts", "programs"
  add_foreign_key "accounts", "users"
  add_foreign_key "attendance_selections", "children"
  add_foreign_key "care_items", "children"
  add_foreign_key "drop_ins", "accounts"
  add_foreign_key "drop_ins", "children"
  add_foreign_key "drop_ins", "locations"
  add_foreign_key "drop_ins", "programs"
  add_foreign_key "emergency_contacts", "accounts"
  add_foreign_key "enrollment_change_transactions", "transactions", column: "my_transaction_id"
  add_foreign_key "enrollment_changes", "accounts"
  add_foreign_key "enrollment_changes", "enrollments"
  add_foreign_key "enrollment_transactions", "transactions", column: "my_transaction_id"
  add_foreign_key "enrollments", "children"
  add_foreign_key "enrollments", "locations"
  add_foreign_key "enrollments", "plans"
  add_foreign_key "plans", "programs"
  add_foreign_key "programs", "centers"
  add_foreign_key "subscriptions", "accounts"
  add_foreign_key "time_disputes", "locations"
  add_foreign_key "transactions", "accounts"
  add_foreign_key "transactions", "programs"
end
