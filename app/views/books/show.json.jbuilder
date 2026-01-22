# frozen_string_literal: true

json.extract! @book, :id, :name, :ordinal, :slug, :created_at, :updated_at
json.bible do
  json.id @book.bible.id
  json.name @book.bible.name
  json.abbreviation @book.bible.abbreviation
  json.slug @book.bible.slug
  json.path bible_path(@book.bible, format: :json)
end
json.testament do
  json.slug @book.testament.slug
  json.path testament_path(@book.testament, format: :json)
end
