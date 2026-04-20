class AddVerseUuidToStudyVerses < ActiveRecord::Migration[8.1]
  def change
    add_column :study_verses, :verse_uuid, :string
    add_index :study_verses, :verse_uuid
  end
end
