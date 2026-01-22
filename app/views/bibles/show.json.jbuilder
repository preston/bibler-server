# frozen_string_literal: true

json.extract! @bible, :id, :name, :abbreviation, :slug, :language, :license, :created_at, :updated_at

# Optionally include books if requested
if params[:include]&.split(',')&.include?('books')
  json.books @bible.books.includes(:testament).order('testament_id ASC', 'ordinal ASC') do |book|
    json.extract! book, :id, :name, :ordinal, :slug, :created_at, :updated_at
    json.testament do
      json.slug book.testament.slug
      json.path testament_path(book.testament, format: :json)
    end
  end
end
