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

ActiveRecord::Schema.define(:version => 20131011141120) do

  create_table "feed_categories", :force => true do |t|
    t.string   "name"
    t.string   "image"
    t.string   "colour"
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "feed_content_redirects", :force => true do |t|
    t.integer  "feed_content_id", :null => false
    t.integer  "user_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "feed_content_users", :id => false, :force => true do |t|
    t.integer "feed_content_id", :null => false
    t.integer "user_id",         :null => false
  end

  add_index "feed_content_users", ["feed_content_id", "user_id"], :name => "index_feed_content_users_on_feed_content_id_and_user_id", :unique => true

  create_table "feed_contents", :force => true do |t|
    t.string   "title"
    t.string   "url"
    t.text     "description"
    t.datetime "pub_date"
    t.integer  "feed_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "feed_users", :id => false, :force => true do |t|
    t.integer "feed_id", :null => false
    t.integer "user_id", :null => false
  end

  add_index "feed_users", ["feed_id", "user_id"], :name => "index_feeds_users_on_feed_id_and_user_id", :unique => true

  create_table "feeds", :force => true do |t|
    t.string   "name"
    t.string   "url"
    t.string   "image"
    t.integer  "user_id"
    t.integer  "feed_category_id"
    t.string   "feed_type"
    t.string   "colour"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
    t.integer  "last_updated",     :default => 0
    t.boolean  "private"
  end

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "roles_users", :id => false, :force => true do |t|
    t.integer "role_id"
    t.integer "user_id"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.string   "username"
    t.datetime "this_visit"
    t.datetime "last_visit"
    t.string   "feed_display_setting"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
