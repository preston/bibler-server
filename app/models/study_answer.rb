# frozen_string_literal: true

# Author: Preston Lee
class StudyAnswer < ApplicationRecord
  belongs_to :study_question
  belongs_to :study
  belongs_to :study_commentary, optional: true
  belongs_to :user, optional: true

  VISIBILITIES = %w[study leaders private].freeze

  before_validation :ensure_uuid
  before_validation :set_author_label_from_user

  validates :uuid, presence: true, uniqueness: true
  validates :response, presence: true
  validates :visibility, inclusion: { in: VISIBILITIES }

  private

  def ensure_uuid
    self.uuid ||= SecureRandom.uuid
  end

  def set_author_label_from_user
    return unless user

    self.author_label = user.username if author_label.blank?
  end
end
