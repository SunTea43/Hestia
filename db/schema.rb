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

ActiveRecord::Schema[8.1].define(version: 2026_04_20_012111) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "charges", force: :cascade do |t|
    t.decimal "amount"
    t.integer "charge_type"
    t.datetime "created_at", null: false
    t.bigint "document_id", null: false
    t.date "due_date"
    t.integer "status"
    t.datetime "updated_at", null: false
    t.index ["document_id"], name: "index_charges_on_document_id"
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

  create_table "document_templates", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.text "description"
    t.bigint "document_type_id"
    t.string "name"
    t.integer "parent_id"
    t.datetime "updated_at", null: false
    t.index ["document_type_id"], name: "index_document_templates_on_document_type_id"
    t.index ["parent_id"], name: "index_document_templates_on_parent_id"
  end

  create_table "document_types", force: :cascade do |t|
    t.string "color"
    t.datetime "created_at", null: false
    t.text "description"
    t.string "icon"
    t.string "name"
    t.string "template_type", default: "html", null: false
    t.datetime "updated_at", null: false
    t.jsonb "variables"
    t.index ["template_type"], name: "index_document_types_on_template_type"
  end

  create_table "documents", force: :cascade do |t|
    t.text "body"
    t.text "co_debtor_info"
    t.datetime "created_at", null: false
    t.integer "document_template_id"
    t.date "end_date"
    t.jsonb "metadata"
    t.string "name"
    t.bigint "occupant_id", null: false
    t.integer "parent_id"
    t.bigint "property_id", null: false
    t.date "start_date"
    t.string "status"
    t.decimal "tenant_income"
    t.datetime "updated_at", null: false
    t.index ["document_template_id"], name: "index_documents_on_document_template_id"
    t.index ["occupant_id"], name: "index_documents_on_occupant_id"
    t.index ["parent_id"], name: "index_documents_on_parent_id"
    t.index ["property_id"], name: "index_documents_on_property_id"
  end

  create_table "occupants", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "document_number"
    t.string "email"
    t.string "name", null: false
    t.string "phone"
    t.datetime "updated_at", null: false
    t.index ["document_number"], name: "index_occupants_on_document_number"
    t.index ["email"], name: "index_occupants_on_email"
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

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "charges", "documents"
  add_foreign_key "company_managers", "companies"
  add_foreign_key "company_managers", "users"
  add_foreign_key "document_templates", "document_templates", column: "parent_id"
  add_foreign_key "document_templates", "document_types"
  add_foreign_key "documents", "document_templates"
  add_foreign_key "documents", "documents", column: "parent_id"
  add_foreign_key "documents", "occupants"
  add_foreign_key "documents", "properties"
  add_foreign_key "properties", "companies"
end
