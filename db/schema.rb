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

ActiveRecord::Schema.define(version: 20140321060321) do

  create_table "challenge_flags", id: false, force: true do |t|
    t.integer  "user_id"
    t.integer  "challenge_id"
    t.string   "value"
    t.string   "nonce"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "challenge_flags", ["user_id", "challenge_id"], name: "index_challenge_flags_on_user_id_and_challenge_id", unique: true, using: :btree

  create_table "challenge_groups", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "visible",     default: 1
  end

  create_table "challenge_hints", force: true do |t|
    t.integer  "challenge_id"
    t.text     "hint_text"
    t.integer  "cost",         default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "challenges", force: true do |t|
    t.string   "name"
    t.string   "challenge_group_id"
    t.string   "url"
    t.text     "description"
    t.integer  "points"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "flag_type"
    t.text     "flag_data"
  end

  add_index "challenges", ["challenge_group_id"], name: "index_challenges_on_challenge_group_id", using: :btree

  create_table "roles", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sessions", force: true do |t|
    t.string   "session_id", null: false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", using: :btree
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree

  create_table "user_challenge_hints", force: true do |t|
    t.integer "user_id"
    t.integer "challenge_hint_id"
  end

  create_table "user_completed_challenges", force: true do |t|
    t.integer  "user_id"
    t.integer  "challenge_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_completed_challenges", ["user_id", "challenge_id"], name: "index_user_completed_challenges_on_user_id_and_challenge_id", unique: true, using: :btree

  create_table "user_message_contents", force: true do |t|
    t.integer  "user_id"
    t.string   "from_name"
    t.string   "subject"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_messages", force: true do |t|
    t.integer  "user_message_content_id"
    t.integer  "user_id"
    t.boolean  "read"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_roles", force: true do |t|
    t.integer "user_id"
    t.integer "role_id"
  end

  create_table "users", force: true do |t|
    t.string   "username",               default: "", null: false
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "points",                 default: 0
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["username"], name: "index_users_on_username", unique: true, using: :btree

end
