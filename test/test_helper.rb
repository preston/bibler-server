# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../config/environment', __dir__)
require 'rails/test_help'

require 'minitest/pride'

require 'bibler'

include Bibler::Data # rubocop:disable Style/MixinUsage

# Author: Preston Lee
module ActiveSupport
  # Author: Preston Lee
  class TestCase
    Testament.destroy_all
    Bible.destroy_all
    Book.destroy_all
    Verse.destroy_all
    
    # Create testaments for tests
    create_testaments

    # Create test bibles if they don't exist
    bible1 = Bible.find_or_create_by(abbreviation: 'TEST1') do |b|
      b.name = 'Test Bible 1'
      b.language = 'en'
      b.license = 'Test License'
    end

    bible2 = Bible.find_or_create_by(abbreviation: 'TEST2') do |b|
      b.name = 'Test Bible 2'
      b.language = 'en'
      b.license = 'Test License'
    end

    # Get testaments
    old_testament = Testament.find_by(name: 'Old')
    new_testament = Testament.find_by(name: 'New')

    # Create test books for each bible
    book1_bible1 = Book.find_or_create_by(bible: bible1, name: 'Genesis') do |b|
      b.testament = old_testament
      b.ordinal = 1
    end

    book1_bible2 = Book.find_or_create_by(bible: bible2, name: 'Genesis') do |b|
      b.testament = old_testament
      b.ordinal = 1
    end

    Verse.create!(bible: bible1, book: book1_bible1, chapter: 1, ordinal: 1,
                  text: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.')
    Verse.create!(bible: bible1, book: book1_bible1, chapter: 1, ordinal: 2,
                  text: 'Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.')
    Verse.create!(bible: bible2, book: book1_bible2, chapter: 1, ordinal: 1,
                  text: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.')
    Verse.create!(bible: bible2, book: book1_bible2, chapter: 1, ordinal: 2,
                  text: 'Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.')

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    # fixtures :all

    # fixtures :bibles, :testaments, :books, :verses

    # Add more helper methods to be used by all tests here...
  end
end
