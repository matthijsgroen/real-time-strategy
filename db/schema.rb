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

ActiveRecord::Schema.define(:version => 20100212165503) do

  create_table "asset_movements", :force => true do |t|
    t.integer     "asset_id"
    t.datetime    "arrival_at"
    t.datetime    "created_at"
    t.datetime    "updated_at"
    t.line_string "path",             :limit => nil
    t.datetime    "departure_at"
    t.integer     "game_instance_id"
  end

  add_index "asset_movements", ["path"], :name => "index_asset_movements_on_path", :spatial => true

  create_table "asset_proximity_triggers", :force => true do |t|
    t.integer  "alerted_asset_id"
    t.integer  "asset_in_proximity_id"
    t.integer  "movement_id"
    t.integer  "game_instance_id"
    t.datetime "in_range_at"
    t.datetime "out_of_range_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "asset_states", :force => true do |t|
    t.integer  "asset_id"
    t.string   "state"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "assets", :force => true do |t|
    t.integer     "game_instance_id"
    t.integer     "faction_id"
    t.string      "type"
    t.string      "state"
    t.integer     "part_of_id"
    t.integer     "bound_to_id"
    t.datetime    "created_at"
    t.datetime    "updated_at"
    t.point       "location",         :limit => nil
    t.line_string "ground_space",     :limit => nil
    t.integer     "target_asset_id"
    t.datetime    "deleted_at"
    t.float       "action_radius"
  end

  add_index "assets", ["ground_space"], :name => "index_assets_on_ground_space", :spatial => true
  add_index "assets", ["location"], :name => "index_assets_on_location", :spatial => true

  create_table "faction_catalog_items", :force => true do |t|
    t.integer  "catalog_id"
    t.string   "item_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "faction_catalogs", :force => true do |t|
    t.integer  "faction_id"
    t.string   "asset_type"
    t.string   "ability"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "faction_messages", :force => true do |t|
    t.integer  "faction_id"
    t.string   "sender"
    t.string   "message"
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "faction_selected_assets", :id => false, :force => true do |t|
    t.integer "asset_id"
    t.integer "selection_id"
  end

  create_table "faction_selections", :force => true do |t|
    t.integer  "faction_id"
    t.integer  "hotkey"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "factions", :force => true do |t|
    t.integer  "game_instance_id"
    t.string   "name"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "game_instances", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "game_start"
    t.datetime "game_paused_at"
    t.integer  "pause_time"
  end

  create_table "resource_group_resources", :id => false, :force => true do |t|
    t.integer "resource_id"
    t.integer "resource_group_id"
  end

  create_table "resource_groups", :force => true do |t|
    t.integer  "owner_id"
    t.string   "owner_type"
    t.string   "name"
    t.integer  "amount_limit"
    t.datetime "depleted_at"
    t.datetime "limit_reached_at"
    t.integer  "start_amount"
    t.datetime "start_amount_at"
    t.integer  "game_instance_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "resources", :force => true do |t|
    t.integer  "owner_id"
    t.string   "owner_type"
    t.string   "name"
    t.integer  "start_amount"
    t.datetime "start_amount_at"
    t.integer  "amount_hour"
    t.integer  "bulk_income"
    t.integer  "amount_limit"
    t.datetime "limit_reached_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "depleted_at"
    t.integer  "game_instance_id"
  end

  create_table "script_assets", :id => false, :force => true do |t|
    t.integer "script_id"
    t.integer "asset_id"
  end

  create_table "scripts", :force => true do |t|
    t.integer  "game_instance_id"
    t.integer  "faction_id"
    t.string   "type"
    t.integer  "parent_id"
    t.datetime "start_time"
    t.datetime "end_time"
    t.text     "parameters"
    t.integer  "position"
    t.integer  "initiated_by_id"
    t.string   "initiated_by_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "timed_events", :force => true do |t|
    t.integer  "game_instance_id"
    t.datetime "time_trigger"
    t.integer  "event_id"
    t.string   "event_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
