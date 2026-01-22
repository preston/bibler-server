# frozen_string_literal: true

json.array!(@bibles) do |b|
  json.extract! b, :id, :name, :abbreviation, :slug, :language, :license, :created_at, :updated_at
end
