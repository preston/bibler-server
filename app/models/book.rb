# frozen_string_literal: true

# Author: Preston Lee
class Book < ActiveRecord::Base
  has_many :verses, dependent: :destroy
  belongs_to :testament

  extend FriendlyId
  friendly_id :name, use: %i[slugged finders]

  validates_presence_of :name
  validates_uniqueness_of :name

  # def verse_count(bible)
  #   verses.where(bible:).count
  # end

  def verse_count(bible, chapter = 0)
    return verses.where(bible:).count if chapter.zero?

    verses.where(bible:, chapter:).count
  end
end
