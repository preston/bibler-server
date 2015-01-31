class Book < ActiveRecord::Base

	has_many :verses, dependent: :destroy
	belongs_to :testament

	extend FriendlyId
	friendly_id :name, use: [:slugged, :finders]

	validates_presence_of :name
	validates_uniqueness_of :name

	def verse_count(bible)
		self.verses.where(bible: bible).count
	end

	def verse_count(bible, chapter = 0)
		if chapter == 0
			return self.verses.where(bible: bible).count
		else
			return self.verses.where(bible: bible, chapter: chapter).count
		end
	end

end
