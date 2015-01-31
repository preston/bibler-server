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

ActiveRecord::Schema.define(version: 1) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "bibles", force: :cascade do |t|
    t.string   "name",         null: false
    t.string   "abbreviation", null: false
    t.string   "slug",         null: false
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "bibles", ["abbreviation"], name: "index_bibles_on_abbreviation", unique: true, using: :btree
  add_index "bibles", ["name"], name: "index_bibles_on_name", unique: true, using: :btree
  add_index "bibles", ["slug"], name: "index_bibles_on_slug", unique: true, using: :btree

  create_table "books", force: :cascade do |t|
    t.integer  "testament_id", null: false
    t.integer  "ordinal",      null: false
    t.string   "name",         null: false
    t.string   "slug",         null: false
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "books", ["name"], name: "index_books_on_name", unique: true, using: :btree
  add_index "books", ["ordinal"], name: "index_books_on_ordinal", using: :btree
  add_index "books", ["slug"], name: "index_books_on_slug", unique: true, using: :btree

  create_table "testaments", force: :cascade do |t|
    t.string   "name",       null: false
    t.string   "slug",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "testaments", ["name"], name: "index_testaments_on_name", unique: true, using: :btree

  create_table "verses", force: :cascade do |t|
    t.integer  "bible_id",   null: false
    t.integer  "book_id",    null: false
    t.integer  "chapter",    null: false
    t.integer  "ordinal",    null: false
    t.text     "text",       null: false
    t.string   "slug",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "verses", ["slug"], name: "index_verses_on_slug", using: :btree
  add_index "verses", ["text"], name: "index_verses_on_text", using: :btree

  add_foreign_key "books", "testaments"
  add_foreign_key "verses", "bibles"
  add_foreign_key "verses", "books"
end
