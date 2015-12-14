json.array!(@bibles) do |b|
	json.extract! b, :id, :name, :abbreviation, :slug, :created_at, :updated_at
end