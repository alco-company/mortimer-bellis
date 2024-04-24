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

ActiveRecord::Schema[7.2].define(version: 2024_04_24_153442) do
  create_table "accounts", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "pp_identification"
    t.string "locale"
    t.string "time_zone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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

  add_foreign_key "filters", "accounts"
  add_foreign_key "locations", "accounts"
end
