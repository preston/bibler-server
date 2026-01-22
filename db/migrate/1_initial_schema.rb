# frozen_string_literal: true

class InitialSchema < ActiveRecord::Migration[8.1]
  def change
   # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "bibles", id: :serial, force: :cascade do |t|
    t.string "abbreviation", null: false
    t.datetime "created_at", precision: nil, null: false
    t.string "language", default: "", null: false
    t.text "license", default: ""
    t.string "name", null: false
    t.string "slug", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["abbreviation"], name: "index_bibles_on_abbreviation", unique: true
    t.index ["name", "language"], name: "index_bibles_on_name_and_language", unique: true
    t.index ["slug"], name: "index_bibles_on_slug", unique: true
  end

  create_table "books", id: :serial, force: :cascade do |t|
    t.bigint "bible_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.string "name", null: false
    t.integer "ordinal", null: false
    t.string "slug", null: false
    t.integer "testament_id", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["bible_id", "name"], name: "index_books_on_bible_id_and_name", unique: true
    t.index ["bible_id", "slug"], name: "index_books_on_bible_id_and_slug"
    t.index ["bible_id"], name: "index_books_on_bible_id"
    t.index ["ordinal"], name: "index_books_on_ordinal"
  end

  create_table "testaments", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.string "name", null: false
    t.string "slug", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["name"], name: "index_testaments_on_name", unique: true
  end

  create_table "verses", id: :serial, force: :cascade do |t|
    t.integer "bible_id", null: false
    t.integer "book_id", null: false
    t.integer "chapter", null: false
    t.datetime "created_at", precision: nil, null: false
    t.integer "ordinal", null: false
    t.string "slug", null: false
    t.text "text", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index "to_tsvector('simple'::regconfig, COALESCE(text, ''::text))", name: "verses_gin_text", using: :gin
    t.index ["slug"], name: "index_verses_on_slug"
  end

  add_foreign_key "books", "bibles"
  add_foreign_key "books", "testaments"
  add_foreign_key "verses", "bibles"
  add_foreign_key "verses", "books"
  end
end
