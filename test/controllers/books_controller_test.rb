require 'test_helper'

class BooksControllerTest < ActionController::TestCase

	setup do
		@bible = Bible.first
		@book = Book.first
	end

	test "should get index" do
		get :index, format: :json
		assert_response :success
	end

	test "should show book" do
		# get :get, book: @book.slug, format: :json
		get :show, params: {id: @book, format: :json}
		assert_not_nil assigns(:book)
		assert_response :success
	end

end
