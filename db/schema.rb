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

ActiveRecord::Schema[8.1].define(version: 2026_11_14_193700) do
  create_table "children", force: :cascade do |t|
    t.string "name", null: false
    t.date "birth_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "doses", force: :cascade do |t|
    t.integer "child_id", null: false
    t.integer "medicine_id", null: false
    t.integer "user_id", null: false
    t.datetime "given_at", null: false
    t.decimal "amount", precision: 6, scale: 2, null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["child_id", "given_at"], name: "index_doses_on_child_id_and_given_at"
    t.index ["child_id"], name: "index_doses_on_child_id"
    t.index ["medicine_id"], name: "index_doses_on_medicine_id"
    t.index ["user_id"], name: "index_doses_on_user_id"
  end

  create_table "medicines", force: :cascade do |t|
    t.integer "child_id", null: false
    t.string "name", null: false
    t.decimal "dose_amount", precision: 6, scale: 2, null: false
    t.string "dose_unit", default: "ml", null: false
    t.integer "min_interval_minutes", null: false
    t.integer "max_doses_per_24h", null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["child_id"], name: "index_medicines_on_child_id"
  end

  create_table "temperatures", force: :cascade do |t|
    t.integer "child_id", null: false
    t.integer "user_id", null: false
    t.datetime "measured_at", null: false
    t.decimal "celsius", precision: 3, scale: 1, null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["child_id", "measured_at"], name: "index_temperatures_on_child_id_and_measured_at"
    t.index ["child_id"], name: "index_temperatures_on_child_id"
    t.index ["user_id"], name: "index_temperatures_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "sub"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_users_on_name"
    t.index ["sub"], name: "index_users_on_sub", unique: true
  end

  add_foreign_key "doses", "children"
  add_foreign_key "doses", "medicines"
  add_foreign_key "doses", "users"
  add_foreign_key "medicines", "children"
  add_foreign_key "temperatures", "children"
  add_foreign_key "temperatures", "users"
end
