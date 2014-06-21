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

ActiveRecord::Schema.define(version: 20140619063921) do

  create_table "activities", force: true do |t|
    t.string   "Name"
    t.string   "City"
    t.string   "State"
    t.string   "StreetAddress1"
    t.string   "StreetAddress2"
    t.string   "Country"
    t.string   "LocationName"
    t.string   "Website"
    t.integer  "Views"
    t.integer  "OrganizerUserId"
    t.integer  "ActivityId"
    t.integer  "ActivityTypeId"
    t.integer  "ModUserId"
    t.integer  "CreateUserId"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "ActivityDate"
    t.time     "ActivityTime"
    t.integer  "user_id"
    t.string   "Description"
    t.boolean  "rsvp"
  end

  create_table "activities_activity_types", id: false, force: true do |t|
    t.integer "activity_id",      null: false
    t.integer "activity_type_id", null: false
  end

  create_table "activity_types", force: true do |t|
    t.string   "Type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "followings", force: true do |t|
    t.integer  "user_id1"
    t.integer  "user_id2"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "photo_activities", force: true do |t|
    t.integer  "Activity_id"
    t.string   "PhotoId"
    t.boolean  "MainPhoto"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "profile_photos", force: true do |t|
    t.integer  "Users_id"
    t.string   "PhotoId"
    t.boolean  "MainPhoto"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "FirstName"
    t.string   "LastName"
    t.string   "email"
    t.string   "password_digest"
    t.string   "UserId"
    t.datetime "Birthday"
    t.string   "Sex"
    t.integer  "ModUserId"
    t.integer  "CreateUserId"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token"
    t.text     "AboutMe"
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "provider"
    t.string   "uid"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["remember_token"], name: "index_users_on_remember_token", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
