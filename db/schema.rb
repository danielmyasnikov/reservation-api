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

ActiveRecord::Schema[7.0].define(version: 2023_08_03_034512) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "guests", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.text "phone", default: [], null: false, array: true
    t.string "email", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_guests_on_email"
  end

  create_table "request_loggers", force: :cascade do |t|
    t.string "endpoint"
    t.string "request_id"
    t.json "payload", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "reservations", force: :cascade do |t|
    t.string "code"
    t.date "start_date"
    t.date "end_date"
    t.float "payout_price", default: 0.0
    t.float "security_price", default: 0.0
    t.float "total_price", default: 0.0
    t.string "currency"
    t.integer "nights", default: 0
    t.integer "guests", default: 0
    t.integer "adults", default: 0
    t.integer "children", default: 0
    t.integer "infants", default: 0
    t.string "status", default: "draft"
    t.bigint "guest_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code", "guest_id"], name: "index_reservations_on_code_and_guest_id", unique: true
    t.index ["guest_id"], name: "index_reservations_on_guest_id"
    t.index ["status"], name: "index_reservations_on_status"
  end

  add_foreign_key "reservations", "guests"
end
