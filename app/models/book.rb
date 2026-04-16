# frozen_string_literal: true

# Author: Preston Lee
class Book < ApplicationRecord
  has_many :verses, dependent: :destroy
  belongs_to :bible
  belongs_to :testament
  before_validation :ensure_uuid

  validates_presence_of :name
  validates_presence_of :uuid
  validates_uniqueness_of :name, scope: :bible_id
  validates_uniqueness_of :uuid

  # def verse_count(bible)
  #   verses.where(bible:).count
  # end

  def verse_count(bible, chapter = 0)
    return verses.where(bible:).count if chapter.zero?

    verses.where(bible:, chapter:).count
  end

  private

  def ensure_uuid
    self.uuid ||= SecureRandom.uuid
  end
end
