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

ActiveRecord::Schema.define(version: 2019_02_13_210723) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "friendships", id: false, force: :cascade do |t|
    t.integer "friender_id"
    t.integer "friendee_id"
    t.index ["friendee_id", "friender_id"], name: "index_friendships_on_friendee_id_and_friender_id", unique: true
    t.index ["friender_id", "friendee_id"], name: "index_friendships_on_friender_id_and_friendee_id", unique: true
  end

  create_table "members", force: :cascade do |t|
    t.string "name"
    t.string "url"
    t.string "short_url"
    t.jsonb "headers", default: []
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index "to_tsvector('english'::regconfig, (name)::text)", name: "members_name_idx", using: :gin
    t.index "to_tsvector('english'::regconfig, headers)", name: "headers_idx", using: :gin
  end

end
