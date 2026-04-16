# frozen_string_literal: true

# Author: Preston Lee
class StudyQuestion < ApplicationRecord
  belongs_to :study
  has_many :study_answers, dependent: :destroy

  QUESTION_TYPES = %w[discussion observation interpretation application].freeze

  before_validation :ensure_uuid

  validates :uuid, presence: true, uniqueness: true
  validates :prompt, :question_type, presence: true
  validates :question_type, inclusion: { in: QUESTION_TYPES }
  validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  scope :ordered, -> { order(:position, :id) }

  private

  def ensure_uuid
    self.uuid ||= SecureRandom.uuid
  end
end
