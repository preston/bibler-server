# frozen_string_literal: true

# Author: Preston Lee
class Testament < ApplicationRecord
  has_many :books, dependent: :destroy
  before_validation :ensure_uuid

  validates_presence_of :name
  validates_presence_of :uuid
  validates_uniqueness_of :name
  validates_uniqueness_of :uuid

  private

  def ensure_uuid
    self.uuid ||= SecureRandom.uuid
  end
end
