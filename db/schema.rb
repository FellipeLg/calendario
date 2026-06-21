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

ActiveRecord::Schema[8.1].define(version: 2026_06_19_001819) do
  create_table "availabilities", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "date", null: false
    t.time "end_time"
    t.text "note"
    t.integer "person_id", null: false
    t.time "start_time"
    t.string "status", null: false
    t.datetime "updated_at", null: false
    t.index ["person_id", "date"], name: "index_availabilities_on_person_id_and_date"
    t.index ["person_id"], name: "index_availabilities_on_person_id"
    t.index ["status"], name: "index_availabilities_on_status"
  end

  create_table "event_participants", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "event_id", null: false
    t.integer "person_id", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id", "person_id"], name: "index_event_participants_on_event_id_and_person_id", unique: true
    t.index ["event_id"], name: "index_event_participants_on_event_id"
    t.index ["person_id"], name: "index_event_participants_on_person_id"
  end

  create_table "events", force: :cascade do |t|
    t.boolean "conflict_confirmed", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "ends_at", null: false
    t.integer "group_id", null: false
    t.text "note"
    t.datetime "starts_at", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id", "starts_at"], name: "index_events_on_group_id_and_starts_at"
    t.index ["group_id"], name: "index_events_on_group_id"
  end

  create_table "groups", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.string "share_token", null: false
    t.datetime "updated_at", null: false
    t.index ["share_token"], name: "index_groups_on_share_token", unique: true
  end

  create_table "people", force: :cascade do |t|
    t.string "color", null: false
    t.string "contact"
    t.datetime "created_at", null: false
    t.integer "group_id", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id", "name"], name: "index_people_on_group_id_and_name"
    t.index ["group_id"], name: "index_people_on_group_id"
  end

  add_foreign_key "availabilities", "people"
  add_foreign_key "event_participants", "events"
  add_foreign_key "event_participants", "people"
  add_foreign_key "events", "groups"
  add_foreign_key "people", "groups"
end
