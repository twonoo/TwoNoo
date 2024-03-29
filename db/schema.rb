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

ActiveRecord::Schema.define(version: 20150927210934) do

  create_table "activities", force: :cascade do |t|
    t.string   "activity_name",      limit: 255
    t.string   "location_name",      limit: 255
    t.string   "street_address_1",   limit: 255
    t.string   "street_address_2",   limit: 255
    t.string   "city",               limit: 255
    t.string   "state",              limit: 255
    t.string   "country",            limit: 255
    t.string   "website",            limit: 255
    t.integer  "activity_type_id",   limit: 4
    t.text     "description",        limit: 65535
    t.integer  "views",              limit: 4
    t.integer  "user_id",            limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "datetime"
    t.boolean  "rsvp",               limit: 1,     default: false
    t.float    "latitude",           limit: 24
    t.float    "longitude",          limit: 24
    t.string   "image_file_name",    limit: 255
    t.string   "image_content_type", limit: 255
    t.integer  "image_file_size",    limit: 4
    t.datetime "image_updated_at"
    t.boolean  "alerted",            limit: 1,     default: false
    t.boolean  "cancelled",          limit: 1,     default: false
    t.string   "tz",                 limit: 255
    t.datetime "enddatetime"
    t.string   "campaign",           limit: 255
  end

  create_table "activities_activity_types", id: false, force: :cascade do |t|
    t.integer  "activity_id",      limit: 4
    t.integer  "activity_type_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "activities_interests", id: false, force: :cascade do |t|
    t.integer  "activity_id", limit: 4
    t.integer  "interest_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "activity_types", force: :cascade do |t|
    t.string   "activity_type", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "alerts", force: :cascade do |t|
    t.string   "keywords",   limit: 255
    t.string   "location",   limit: 255
    t.integer  "distance",   limit: 4
    t.integer  "user_id",    limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "comments", force: :cascade do |t|
    t.string   "title",            limit: 50,    default: ""
    t.text     "comment",          limit: 65535
    t.integer  "commentable_id",   limit: 4
    t.string   "commentable_type", limit: 255
    t.integer  "user_id",          limit: 4
    t.string   "role",             limit: 255,   default: "comments"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["commentable_id"], name: "index_comments_on_commentable_id", using: :btree
  add_index "comments", ["commentable_type"], name: "index_comments_on_commentable_type", using: :btree
  add_index "comments", ["user_id"], name: "index_comments_on_user_id", using: :btree

  create_table "follow_relationships", force: :cascade do |t|
    t.integer  "follower_id", limit: 4
    t.integer  "followed_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "geocodes", force: :cascade do |t|
    t.string   "city",       limit: 255
    t.string   "state",      limit: 255
    t.float    "latitude",   limit: 24
    t.float    "longitude",  limit: 24
    t.string   "timezone",   limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "interests", force: :cascade do |t|
    t.string  "name",   limit: 255,                null: false
    t.string  "code",   limit: 255,                null: false
    t.boolean "active", limit: 1,   default: true, null: false
  end

  create_table "interests_options", force: :cascade do |t|
    t.integer "interest_id",  limit: 4,                  null: false
    t.string  "option_name",  limit: 255,                null: false
    t.string  "option_value", limit: 255
    t.string  "code",         limit: 255,                null: false
    t.boolean "active",       limit: 1,   default: true, null: false
  end

  create_table "interests_users", id: false, force: :cascade do |t|
    t.integer "user_id",             limit: 4, null: false
    t.integer "interest_id",         limit: 4, null: false
    t.integer "interests_option_id", limit: 4
  end

  create_table "likes", force: :cascade do |t|
    t.integer  "user_id",      limit: 4,   null: false
    t.integer  "activity_id",  limit: 4,   null: false
    t.string   "referrer_uri", limit: 255, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mailboxer_conversation_opt_outs", force: :cascade do |t|
    t.integer "unsubscriber_id",   limit: 4
    t.string  "unsubscriber_type", limit: 255
    t.integer "conversation_id",   limit: 4
  end

  add_index "mailboxer_conversation_opt_outs", ["conversation_id"], name: "mb_opt_outs_on_conversations_id", using: :btree

  create_table "mailboxer_conversations", force: :cascade do |t|
    t.string   "subject",    limit: 255, default: ""
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  create_table "mailboxer_notifications", force: :cascade do |t|
    t.string   "type",                 limit: 255
    t.text     "body",                 limit: 65535
    t.string   "subject",              limit: 255,   default: ""
    t.integer  "sender_id",            limit: 4
    t.string   "sender_type",          limit: 255
    t.integer  "conversation_id",      limit: 4
    t.boolean  "draft",                limit: 1,     default: false
    t.string   "notification_code",    limit: 255
    t.integer  "notified_object_id",   limit: 4
    t.string   "notified_object_type", limit: 255
    t.string   "attachment",           limit: 255
    t.datetime "updated_at",                                         null: false
    t.datetime "created_at",                                         null: false
    t.boolean  "global",               limit: 1,     default: false
    t.datetime "expires"
  end

  add_index "mailboxer_notifications", ["conversation_id"], name: "index_mailboxer_notifications_on_conversation_id", using: :btree

  create_table "mailboxer_receipts", force: :cascade do |t|
    t.integer  "receiver_id",     limit: 4
    t.string   "receiver_type",   limit: 255
    t.integer  "notification_id", limit: 4,                   null: false
    t.boolean  "is_read",         limit: 1,   default: false
    t.boolean  "trashed",         limit: 1,   default: false
    t.boolean  "deleted",         limit: 1,   default: false
    t.string   "mailbox_type",    limit: 25
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
  end

  add_index "mailboxer_receipts", ["notification_id"], name: "index_mailboxer_receipts_on_notification_id", using: :btree

  create_table "neighborhoods", force: :cascade do |t|
    t.string   "name",       limit: 255, null: false
    t.string   "city",       limit: 255, null: false
    t.string   "state",      limit: 255, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "notification_settings", force: :cascade do |t|
    t.integer  "profile_id",                    limit: 4
    t.integer  "new_follower",                  limit: 4, default: 2
    t.integer  "new_message",                   limit: 4, default: 1
    t.integer  "new_rsvp",                      limit: 4, default: 1
    t.integer  "new_following_activity",        limit: 4, default: 2
    t.integer  "attending_activity_update",     limit: 4, default: 1
    t.integer  "comment_on_owned_activity",     limit: 4, default: 1
    t.integer  "comment_on_attending_activity", limit: 4, default: 1
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "activity_summary",              limit: 4, default: 3
    t.integer  "activity_reminder",             limit: 4, default: 1
    t.integer  "local_activity_summary",        limit: 4, default: 2
  end

  create_table "profiles", force: :cascade do |t|
    t.integer  "user_id",                      limit: 4
    t.string   "first_name",                   limit: 255
    t.string   "last_name",                    limit: 255
    t.datetime "birthday"
    t.integer  "gender",                       limit: 4
    t.integer  "postcode",                     limit: 4
    t.text     "about_me",                     limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "profile_picture_file_name",    limit: 255
    t.string   "profile_picture_content_type", limit: 255
    t.integer  "profile_picture_file_size",    limit: 4
    t.datetime "profile_picture_updated_at"
    t.integer  "nonprofit",                    limit: 4
    t.integer  "ambassador",                   limit: 4
    t.integer  "referrer",                     limit: 4,     default: 0
    t.string   "city",                         limit: 255
    t.string   "state",                        limit: 255
    t.string   "neighborhood",                 limit: 255
    t.datetime "closed_at"
    t.string   "closed_reason",                limit: 255
    t.float    "city_state_latitude",          limit: 24
    t.float    "city_state_longitude",         limit: 24
  end

  create_table "promotioncodes", force: :cascade do |t|
    t.string   "code",       limit: 255, null: false
    t.string   "campaign",   limit: 255, null: false
    t.integer  "user_id",    limit: 4
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "recommended_followers", force: :cascade do |t|
    t.integer  "user_id",                 limit: 4
    t.integer  "recommended_follower_id", limit: 4
    t.integer  "order",                   limit: 4
    t.datetime "recommended_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "match_criteria",          limit: 255
    t.string   "match_data",              limit: 255
    t.boolean  "ignored",                 limit: 1,   default: false
  end

  create_table "rsvps", force: :cascade do |t|
    t.integer  "activity_id", limit: 4
    t.integer  "user_id",     limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "searches", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.text     "search",     limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "location",   limit: 255
  end

  create_table "transaction_types", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "transactions", force: :cascade do |t|
    t.integer  "transaction_type_id", limit: 4
    t.integer  "amount",              limit: 4
    t.float    "cost",                limit: 24
    t.integer  "balance",             limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "comment",             limit: 65535
    t.integer  "activity_id",         limit: 4
    t.integer  "user_id",             limit: 4
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "", null: false
    t.string   "encrypted_password",     limit: 255, default: "", null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,   default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "provider",               limit: 255
    t.string   "uid",                    limit: 255
    t.string   "confirmation_token",     limit: 255
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email",      limit: 255
    t.string   "last_search_location",   limit: 255
    t.string   "last_search_lat",        limit: 255
    t.string   "last_search_lon",        limit: 255
    t.string   "gcal_token",             limit: 255
    t.datetime "gcal_token_issued_at"
    t.integer  "gcal_token_expires_in",  limit: 4
    t.string   "gcal_refresh_token",     limit: 255
    t.string   "fb_token",               limit: 500
    t.integer  "fb_token_expires_in",    limit: 4
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "view_logs", force: :cascade do |t|
    t.integer "user_id",   limit: 4
    t.string  "view_name", limit: 255
  end

