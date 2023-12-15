# frozen_string_literal: true

# Author: Preston Lee
class Verse < ActiveRecord::Base
  include PgSearch::Model
  # multisearchable :against => [:text]
  pg_search_scope :search_by_text, against: :text

  belongs_to	:bible
  belongs_to	:book

  extend FriendlyId
  friendly_id :ordinal, use: %i[slugged finders scoped], scope: %i[bible book chapter]

  validates_presence_of :bible
  validates_presence_of :book

  validates_numericality_of :chapter, only_integer: true, greater_than: 0
  validates_numericality_of :ordinal, only_integer: true, greater_than: 0

  validates_uniqueness_of :ordinal, scope: %i[bible book chapter]

  # def slug_candidates
  # 	[
  # 		[:chapter, :ordinal]
  # 	]
  # end
end
