# frozen_string_literal: true

json.array!(@books) do |b|
  json.extract! b, :id, :name, :ordinal, :slug, :created_at, :updated_at
  json.bible do
    json.id b.bible.id
    json.name b.bible.name
    json.abbreviation b.bible.abbreviation
    json.slug b.bible.slug
    json.path bible_path(b.bible, format: :json)
  end
  json.testament do
    json.slug b.testament.slug
    json.path testament_path(b.testament, format: :json)
  end
end
