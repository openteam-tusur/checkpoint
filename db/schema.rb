# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20141003020459) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "attendances", force: true do |t|
    t.string   "kind"
    t.integer  "fact"
    t.integer  "total"
    t.integer  "student_id"
    t.integer  "docket_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "attendances", ["docket_id"], name: "index_attendances_on_docket_id", using: :btree
  add_index "attendances", ["student_id"], name: "index_attendances_on_student_id", using: :btree

  create_table "dockets", force: true do |t|
    t.string   "discipline"
    t.integer  "subdivision_id"
    t.integer  "group_id"
    t.integer  "lecturer_id"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.integer  "period_id"
    t.string   "kind"
    t.integer  "providing_subdivision_id"
    t.string   "discipline_cycle"
  end

  add_index "dockets", ["group_id"], name: "index_dockets_on_group_id", using: :btree
  add_index "dockets", ["lecturer_id"], name: "index_dockets_on_lecturer_id", using: :btree
  add_index "dockets", ["period_id"], name: "index_dockets_on_period_id", using: :btree
  add_index "dockets", ["subdivision_id"], name: "index_dockets_on_subdivision_id", using: :btree

  create_table "grades", force: true do |t|
    t.integer  "mark"
    t.integer  "student_id"
    t.integer  "docket_id"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.boolean  "active",     default: true
    t.string   "type"
  end

  add_index "grades", ["docket_id"], name: "index_grades_on_docket_id", using: :btree
  add_index "grades", ["student_id"], name: "index_grades_on_student_id", using: :btree

  create_table "groups", force: true do |t|
    t.string   "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "course"
    t.integer  "period_id"
    t.integer  "faculty_id"
    t.integer  "chair_id"
  end

  add_index "groups", ["period_id"], name: "index_groups_on_period_id", using: :btree

  create_table "people", force: true do |t|
    t.string   "name"
    t.string   "surname"
    t.string   "patronymic"
    t.string   "type"
    t.integer  "group_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.string   "contingent_id"
  end

  add_index "people", ["group_id"], name: "index_people_on_group_id", using: :btree

  create_table "periods", force: true do |t|
    t.date     "starts_at"
    t.date     "ends_at"
    t.string   "kind"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.string   "season_type"
    t.boolean  "graduate",    default: false
  end

  create_table "permissions", force: true do |t|
    t.string   "user_id"
    t.integer  "context_id"
    t.string   "context_type"
    t.string   "role"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.string   "email"
    t.integer  "old_user_uid"
    t.integer  "old_user_id"
  end

  add_index "permissions", ["user_id", "role", "context_id", "context_type"], name: "by_user_and_role_and_context", using: :btree

  create_table "subdivisions", force: true do |t|
    t.string   "title"
    t.string   "abbr"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "folder_name"
    t.string   "type"
  end

  create_table "users", force: true do |t|
    t.string   "uid"
    t.text     "name"
    t.text     "email"
    t.text     "nickname"
    t.text     "first_name"
    t.text     "last_name"
    t.text     "raw_info"
    t.integer  "sign_in_count"
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  add_index "users", ["uid"], name: "index_users_on_uid", using: :btree

end
