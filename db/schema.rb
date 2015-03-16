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

ActiveRecord::Schema.define(version: 20140321101646) do

  create_table "aide_changes", force: true do |t|
    t.integer  "report_day_id"
    t.string   "file_name"
    t.integer  "action"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "audit_events", force: true do |t|
    t.string   "server_name"
    t.string   "user_name"
    t.string   "ip"
    t.datetime "time_moment"
    t.string   "kind"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "iptables", force: true do |t|
    t.string   "server_name"
    t.integer  "src_ip"
    t.datetime "time_moment"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "penetrations", force: true do |t|
    t.string   "server_name"
    t.string   "vulnerability"
    t.string   "attacker_ip"
    t.string   "attacked_ip"
    t.datetime "time_moment"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "report_days", force: true do |t|
    t.datetime "time_moment"
    t.string   "server_name"
    t.integer  "total_added",   default: 0
    t.integer  "total_removed", default: 0
    t.integer  "total_changed", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
