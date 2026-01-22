# frozen_string_literal: true

class AddLanguageAndLicenseToBibles < ActiveRecord::Migration[7.0]
  def change
    # Remove unique constraint on name (will be scoped to language)
    # Explicitly specify the index name to ensure it's removed
    remove_index :bibles, name: 'index_bibles_on_name'

    # Add language column (not nullable, default empty string)
    add_column :bibles, :language, :string, null: false, default: ''
    add_column :bibles, :license, :text, default: ''

    # Add unique composite index on [name, language] to allow same name for different languages
    add_index :bibles, %i[name language], unique: true, name: 'index_bibles_on_name_and_language'
  end
end
