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

ActiveRecord::Schema.define(version: 20131028051910) do

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
  end

  create_table "users", force: true do |t|
    t.string   "FirstName"
    t.string   "LastName"
    t.string   "Email"
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
  end

  add_index "users", ["remember_token"], name: "index_users_on_remember_token"

end
