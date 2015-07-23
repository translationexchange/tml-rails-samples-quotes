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

ActiveRecord::Schema.define(version: 20150723015508) do

  create_table "authors", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.text     "info"
    t.integer  "quote_count", limit: 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "authors", ["id"], name: "sqlite_autoindex_authors_1", unique: true
  add_index "authors", ["name"], name: "index_authors_on_name"

  create_table "quotes", force: :cascade do |t|
    t.text    "quote",                               null: false
    t.string  "author",     limit: 128, default: "", null: false
    t.text    "authordata",                          null: false
    t.integer "comments",   limit: 11,  default: 0,  null: false
    t.integer "author_id"
  end

  add_index "quotes", ["author_id"], name: "index_quotes_on_author_id"
  add_index "quotes", ["id"], name: "sqlite_autoindex_quotes_1", unique: true

end
