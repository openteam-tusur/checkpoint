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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20131120015844) do

  create_table "attendances", :force => true do |t|
    t.string   "kind"
    t.integer  "fact"
    t.integer  "total"
    t.integer  "student_id"
    t.integer  "docket_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "attendances", ["docket_id"], :name => "index_attendances_on_docket_id"
  add_index "attendances", ["student_id"], :name => "index_attendances_on_student_id"

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0, :null => false
    t.integer  "attempts",   :default => 0, :null => false
    t.text     "handler",                   :null => false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "dockets", :force => true do |t|
    t.string   "discipline"
    t.integer  "subdivision_id"
    t.integer  "group_id"
    t.integer  "lecturer_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.integer  "period_id"
    t.string   "kind"
  end

  add_index "dockets", ["group_id"], :name => "index_dockets_on_group_id"
  add_index "dockets", ["lecturer_id"], :name => "index_dockets_on_lecturer_id"
  add_index "dockets", ["period_id"], :name => "index_dockets_on_period_id"
  add_index "dockets", ["subdivision_id"], :name => "index_dockets_on_subdivision_id"

  create_table "grades", :force => true do |t|
    t.integer  "mark"
    t.integer  "student_id"
    t.integer  "docket_id"
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
    t.boolean  "active",     :default => true
    t.string   "type"
  end

  add_index "grades", ["docket_id"], :name => "index_grades_on_docket_id"
  add_index "grades", ["student_id"], :name => "index_grades_on_student_id"

  create_table "groups", :force => true do |t|
    t.string   "title"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "course"
    t.integer  "period_id"
  end

  add_index "groups", ["period_id"], :name => "index_groups_on_period_id"

  create_table "people", :force => true do |t|
    t.string   "name"
    t.string   "surname"
    t.string   "patronymic"
    t.string   "type"
    t.integer  "group_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.string   "contingent_id"
  end

  add_index "people", ["group_id"], :name => "index_people_on_group_id"

  create_table "periods", :force => true do |t|
    t.date     "starts_at"
    t.date     "ends_at"
    t.string   "kind"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
    t.string   "season_type"
    t.boolean  "graduate",    :default => false
  end

  create_table "permissions", :force => true do |t|
    t.integer  "user_id"
    t.integer  "context_id"
    t.string   "context_type"
    t.string   "role"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.string   "email"
  end

  add_index "permissions", ["user_id", "role", "context_id", "context_type"], :name => "by_user_and_role_and_context"

  create_table "subdivisions", :force => true do |t|
    t.string   "title"
    t.string   "abbr"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.string   "folder_name"
  end

  create_table "users", :force => true do |t|
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
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  add_index "users", ["uid"], :name => "index_users_on_uid"

end
