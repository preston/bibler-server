ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

require 'minitest/pride'

require 'bibler'
include Bibler::Data

class ActiveSupport::TestCase

	Testament.destroy_all
	Bible.destroy_all
	bootstrap!

	Verse.create!(bible: Bible.first, book: Book.first, chapter: 1, ordinal: 1, text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.")
	Verse.create!(bible: Bible.first, book: Book.first, chapter: 1, ordinal: 2, text: "Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.")
	Verse.create!(bible: Bible.last, book: Book.first, chapter: 1, ordinal: 1, text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.")
	Verse.create!(bible: Bible.last, book: Book.first, chapter: 1, ordinal: 2, text: "Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.")

	# Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
	# fixtures :all

	# fixtures :bibles, :testaments, :books, :verses

	# Add more helper methods to be used by all tests here...
end
