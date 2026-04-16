json.extract! study_verse, :uuid, :bible_uuid, :book_uuid, :chapter, :ordinal, :verse_text, :note, :position, :created_at, :updated_at
json.paths do
  json.study study_path(study_verse.study.uuid, format: :json)
end
