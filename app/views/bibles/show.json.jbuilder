# frozen_string_literal: true

json.extract! @bible, :id, :uuid, :name, :abbreviation, :language, :license, :created_at, :updated_at,
              :ai_default_english, :ai_default_hebrew_ot, :ai_default_greek, :ai_default_aramaic

# Optionally include books if requested
if params[:include]&.split(',')&.include?('books')
  json.books @bible.books.includes(:testament).order('testament_id ASC', 'ordinal ASC') do |book|
    json.extract! book, :id, :uuid, :name, :ordinal, :created_at, :updated_at
    json.testament do
      json.uuid book.testament.uuid
      json.path testament_path(book.testament.uuid, format: :json)
    end
  end
end
