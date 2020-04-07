class Verse < ActiveRecord::Base

	include PgSearch::Model
	# multisearchable :against => [:text]
	pg_search_scope :search_by_text, :against => :text

	belongs_to	:bible
	belongs_to	:book

	extend FriendlyId
	friendly_id :ordinal, use: [:slugged, :finders, :scoped], scope: [:bible, :book, :chapter]

	validates_presence_of :bible
	validates_presence_of :book

	validates_numericality_of :chapter, only_integer: true, greater_than: 0
	validates_numericality_of :ordinal, only_integer: true, greater_than: 0

	validates_uniqueness_of :ordinal, scope: [:bible, :book, :chapter]

	# def slug_candidates
	# 	[
	# 		[:chapter, :ordinal]
	# 	]
	# end

end
