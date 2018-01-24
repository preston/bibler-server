class InitialSchema < ActiveRecord::Migration[5.0]

  def change
    create_table :bibles do |t|
      t.string :name, null: false
      t.string :abbreviation, null: false
      t.string :slug, null: false

      t.timestamps null: false
    end
    add_index :bibles, :name, unique: true
    add_index :bibles, :abbreviation, unique: true
    add_index :bibles, :slug, unique: true

    create_table :testaments do |t|
      t.string :name, null: false
      t.string :slug, null: false

      t.timestamps null: false
    end
    add_index :testaments, :name, unique: true


    create_table :books do |t|
      t.integer :testament_id, null: false
      t.integer :ordinal, null: false
      t.string :name, null: false
      t.string :slug, null: false

      t.timestamps null: false
    end
    add_foreign_key :books, :testaments
    add_index :books, :ordinal
    add_index :books, :name, unique: true
    add_index :books, :slug, unique: true

    create_table :verses do |t|
      t.integer :bible_id, null: false
      t.integer :book_id, null: false
      t.integer :chapter, null: false
      t.integer :ordinal, null: false
      t.text :text, null: false
      t.string :slug, null: false

      t.timestamps null: false
    end
    add_foreign_key :verses, :bibles
    add_foreign_key :verses, :books
    add_index :verses, :slug #, unique: true
    add_index :verses, :text #, unique: true

    # Full text index for Postgres.
    execute "CREATE INDEX verses_gin_text ON verses USING GIN(to_tsvector('simple', coalesce(text::TEXT, '')))"

  end


end
