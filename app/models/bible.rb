# frozen_string_literal: true

# Author: Preston Lee
class Bible < ActiveRecord::Base
  has_many :verses, dependent: :destroy

  extend FriendlyId
  friendly_id :slug_candidates, use: %i[slugged finders]

  validates_presence_of :name
  validates_presence_of :abbreviation
  validates_presence_of :slug

  validates_uniqueness_of :name
  validates_uniqueness_of :abbreviation

  def slug_candidates
    [
      [:name],
      %i[name abbreviation]
    ]
  end
end
