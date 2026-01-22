# frozen_string_literal: true

class RemoveVersesTextIndex < ActiveRecord::Migration[8.1]
  def change
    # Remove the btree index on text column - it fails for long verses
    # Full-text search is already covered by the GIN index (verses_gin_text)
    remove_index :verses, name: 'index_verses_on_text'
  end
end
