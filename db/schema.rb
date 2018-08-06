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

ActiveRecord::Schema.define(version: 302) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "courses", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "degrees", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_degrees_on_name", unique: true
  end

  create_table "degrees_courses", id: false, force: :cascade do |t|
    t.bigint "course_id", null: false
    t.bigint "degree_id", null: false
    t.integer "year", limit: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "group_id"
    t.index ["group_id"], name: "index_degrees_courses_on_group_id"
  end

  create_table "events", force: :cascade do |t|
    t.date "date", null: false
    t.time "start_time", null: false
    t.time "end_time", null: false
    t.time "duration", null: false
    t.string "place", default: "", null: false
    t.text "description", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "group_id"
    t.index ["group_id"], name: "index_events_on_group_id"
  end

  create_table "groups", force: :cascade do |t|
    t.string "name", null: false
    t.integer "max_members", limit: 2, default: -1, null: false
    t.boolean "private", default: false, null: false
    t.uuid "uuid", default: -> { "gen_random_uuid()" }, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "course_id"
    t.index ["course_id"], name: "index_groups_on_course_id"
  end

  create_table "invitations", id: false, force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "group_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "memberships", id: false, force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "group_id", null: false
    t.boolean "admin", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "messages", id: false, force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "group_id", null: false
    t.text "text", default: "", null: false
    t.boolean "pinned", default: false, null: false
    t.binary "attachement"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "students", id: false, force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "degree_id", null: false
    t.integer "year", limit: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["name"], name: "index_users_on_name", unique: true
  end

  add_foreign_key "degrees_courses", "groups"
  add_foreign_key "events", "groups"
  add_foreign_key "groups", "courses"
end
