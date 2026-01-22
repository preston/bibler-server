# frozen_string_literal: true

class MakeBooksBibleSpecific < ActiveRecord::Migration[8.1]
  def change
    # Add bible_id to books table
    add_reference :books, :bible, null: false, foreign_key: true

    # Remove unique constraint on books.name (different bibles can have books with the same name)
    remove_index :books, :name

    # Remove unique constraint on books.slug (slugs will be scoped to bible)
    remove_index :books, :slug

    # Add unique composite index on [bible_id, name] to prevent duplicate book names within a bible
    add_index :books, %i[bible_id name], unique: true

    # Add composite index on [bible_id, slug] for friendly_id lookups
    add_index :books, %i[bible_id slug]
  end
end
