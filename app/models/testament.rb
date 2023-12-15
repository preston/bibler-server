# frozen_string_literal: true

# Author: Preston Lee
class Testament < ActiveRecord::Base
  has_many :books, dependent: :destroy

  extend FriendlyId
  friendly_id :name, use: %i[slugged finders]

  validates_presence_of :name
  validates_uniqueness_of :name
end
