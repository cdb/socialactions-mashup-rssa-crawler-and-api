# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 18) do

  create_table "actions", :force => true do |t|
    t.text     "description"
    t.string   "url"
    t.text     "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "feed_id"
    t.decimal  "latitude",    :precision => 15, :scale => 10
    t.decimal  "longitude",   :precision => 15, :scale => 10
    t.string   "location"
    t.integer  "site_id"
    t.string   "action_type"
  end

  create_table "donations", :force => true do |t|
    t.integer  "action_id"
    t.string   "ein"
    t.string   "designation"
    t.string   "dedication"
    t.string   "disclosure"
    t.string   "amount"
    t.string   "identifier"
    t.string   "fee_option"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "donors", :force => true do |t|
    t.integer  "donation_id"
    t.string   "ip_address"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "cc_email"
    t.string   "address1"
    t.string   "address2"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.string   "phone"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "feeds", :force => true do |t|
    t.string   "name"
    t.string   "url"
    t.datetime "last_accessed"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "tag_finder"
    t.integer  "site_id"
    t.string   "location_finder"
    t.string   "action_type"
    t.boolean  "donations",       :default => false, :null => false
  end

  create_table "sites", :force => true do |t|
    t.string   "name"
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type"], :name => "index_taggings_on_taggable_id_and_taggable_type"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

end
