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

ActiveRecord::Schema[7.2].define(version: 2024_04_25_104956) do
  create_table "accounts", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "pp_identification"
    t.string "locale"
    t.string "time_zone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "employees", force: :cascade do |t|
    t.integer "account_id", null: false
    t.integer "team_id", null: false
    t.string "name"
    t.string "pincode"
    t.string "employee_ident"
    t.string "access_token"
    t.datetime "last_punched_at"
    t.string "state"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_employees_on_account_id"
    t.index ["team_id"], name: "index_employees_on_team_id"
  end

  create_table "filters", force: :cascade do |t|
    t.integer "account_id", null: false
    t.string "view"
    t.json "filter"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_filters_on_account_id"
  end

  create_table "locations", force: :cascade do |t|
    t.integer "account_id", null: false
    t.string "name"
    t.string "location_color"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_locations_on_account_id"
  end

  create_table "punch_clocks", force: :cascade do |t|
    t.integer "account_id", null: false
    t.integer "location_id", null: false
    t.string "name"
    t.string "ip_addr"
    t.datetime "last_punched_at"
    t.string "access_token"
    t.string "locale"
    t.string "time_zone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_punch_clocks_on_account_id"
    t.index ["location_id"], name: "index_punch_clocks_on_location_id"
  end

  create_table "teams", force: :cascade do |t|
    t.integer "account_id", null: false
    t.string "name"
    t.string "team_color"
    t.string "locale"
    t.string "time_zone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_teams_on_account_id"
  end

  add_foreign_key "employees", "accounts"
  add_foreign_key "employees", "teams"
  add_foreign_key "filters", "accounts"
  add_foreign_key "filters", "accounts"
  add_foreign_key "filters", "accounts"
  add_foreign_key "locations", "accounts", on_delete: :cascade
  add_foreign_key "punch_clocks", "accounts", on_delete: :cascade
  add_foreign_key "punch_clocks", "locations", on_delete: :cascade
  add_foreign_key "teams", "accounts"
  add_foreign_key "teams", "accounts", on_delete: :cascade
end
