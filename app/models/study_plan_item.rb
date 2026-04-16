class StudyPlanItem < ApplicationRecord
  belongs_to :study
  has_many :study_plan_item_user_states, dependent: :destroy

  ITEM_TYPES = %w[verse commentary question task custom].freeze
  DEFAULT_DURATIONS_BY_TYPE = {
    'verse' => 2,
    'question' => 7,
    'commentary' => 5,
    'task' => 5,
    'custom' => 5
  }.freeze

  before_validation :ensure_uuid
  before_validation :apply_default_duration, on: :create
  scope :ordered, -> { order(:position, :created_at) }

  validates :uuid, presence: true, uniqueness: true
  validates :title, presence: true
  validates :item_type, presence: true, inclusion: { in: ITEM_TYPES }
  validates :position, presence: true
  validates :duration, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
  validate :metadata_must_be_object

  def effective_duration
    return nil if duration.to_i <= 0

    duration
  end

  private

  def ensure_uuid
    self.uuid ||= SecureRandom.uuid
    self.position = 0 if position.nil?
    self.metadata ||= {}
  end

  def apply_default_duration
    return unless duration.nil?

    self.duration = DEFAULT_DURATIONS_BY_TYPE[item_type]
  end

  def metadata_must_be_object
    errors.add(:metadata, 'must be an object') unless metadata.is_a?(Hash)
  end
end
