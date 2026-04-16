# frozen_string_literal: true

# Author: Preston Lee
# A saved scripture reference (bible/book/chapter/ordinal) attached to a study.
class StudyVerse < ApplicationRecord
  belongs_to :study

  before_validation :ensure_uuid

  validates :uuid, presence: true, uniqueness: true
  validates :bible_uuid, :book_uuid, presence: true
  validates :chapter, :ordinal, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  scope :ordered, -> { order(:position, :id) }

  private

  def ensure_uuid
    self.uuid ||= SecureRandom.uuid
  end
end
