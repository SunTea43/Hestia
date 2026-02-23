# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_02_23_045712) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "charges", force: :cascade do |t|
    t.decimal "amount"
    t.integer "charge_type"
    t.bigint "contract_id", null: false
    t.datetime "created_at", null: false
    t.date "due_date"
    t.integer "status"
    t.datetime "updated_at", null: false
    t.index ["contract_id"], name: "index_charges_on_contract_id"
  end

  create_table "companies", force: :cascade do |t|
    t.string "address"
    t.datetime "created_at", null: false
    t.string "name"
    t.string "nit"
    t.datetime "updated_at", null: false
  end

  create_table "company_managers", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["company_id"], name: "index_company_managers_on_company_id"
    t.index ["user_id"], name: "index_company_managers_on_user_id"
  end

  create_table "contracts", force: :cascade do |t|
    t.text "co_debtor_info"
    t.datetime "created_at", null: false
    t.date "end_date"
    t.bigint "property_id", null: false
    t.date "start_date"
    t.bigint "tenant_id", null: false
    t.decimal "tenant_income"
    t.datetime "updated_at", null: false
    t.index ["property_id"], name: "index_contracts_on_property_id"
    t.index ["tenant_id"], name: "index_contracts_on_tenant_id"
  end

  create_table "properties", force: :cascade do |t|
    t.string "address"
    t.boolean "admin_fee_included"
    t.decimal "area"
    t.integer "category"
    t.text "common_areas"
    t.bigint "company_id", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.boolean "has_elevator"
    t.decimal "price"
    t.string "property_type"
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_properties_on_company_id"
  end

  create_table "users", force: :cascade do |t|
    t.date "birth_date"
    t.datetime "created_at", null: false
    t.string "document_number"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "name"
    t.string "phone"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.integer "role"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "charges", "contracts"
  add_foreign_key "company_managers", "companies"
  add_foreign_key "company_managers", "users"
  add_foreign_key "contracts", "properties"
  add_foreign_key "contracts", "users", column: "tenant_id"
  add_foreign_key "properties", "companies"
end
