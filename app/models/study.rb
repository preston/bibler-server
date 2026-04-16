# frozen_string_literal: true

# Author: Preston Lee
class Study < ApplicationRecord
  has_many :study_verses, dependent: :destroy
  has_many :study_commentaries, dependent: :destroy
  has_many :study_questions, dependent: :destroy
  has_many :study_tasks, dependent: :destroy
  has_many :study_answers, dependent: :destroy
  has_many :study_plan_items, dependent: :destroy
  belongs_to :owner, class_name: 'User', optional: true

  VISIBILITIES = %w[private sharable public].freeze
  MODES = %w[leader co-leader participant].freeze

  before_validation :ensure_uuid

  validates :uuid, presence: true, uniqueness: true
  validates :title, presence: true
  validates :visibility, presence: true, inclusion: { in: VISIBILITIES }

  def capabilities_for(mode)
    normalized_mode = MODES.include?(mode) ? mode : 'participant'
    {
      mode: normalized_mode,
      can_edit_structure: %w[leader co-leader].include?(normalized_mode),
      can_manage_tasks: %w[leader co-leader].include?(normalized_mode),
      can_reorder_content: %w[leader co-leader].include?(normalized_mode),
      can_delete_content: %w[leader co-leader].include?(normalized_mode),
      can_answer_questions: true,
      can_delete_study: normalized_mode == 'leader'
    }
  end

  def selected_bible_uuids
    raw = metadata.is_a?(Hash) ? metadata['selected_bible_uuids'] : nil
    return [] unless raw.is_a?(Array)

    raw.map(&:to_s).map(&:strip).reject(&:blank?).uniq
  end

  private

  def ensure_uuid
    self.uuid ||= SecureRandom.uuid
  end
end
