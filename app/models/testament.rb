class Testament < ActiveRecord::Base

	has_many :books, dependent: :destroy

	extend FriendlyId
	friendly_id :name, use: [:slugged, :finders]

	validates_presence_of :name
	validates_uniqueness_of :name

end
