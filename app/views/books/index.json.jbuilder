json.array!(@books) do |b|
	json.extract! b, :id, :name, :ordinal, :slug, :created_at, :updated_at
	json.testament do
		json.slug b.testament.slug
		json.path testament_path(b.testament, format: :json)
	end
end