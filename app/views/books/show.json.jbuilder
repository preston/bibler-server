json.extract! @book, :id, :name, :ordinal, :slug, :created_at, :updated_at
json.testament do
	json.slug @book.testament.slug
	json.path testament_path(@book.testament, format: :json)
end