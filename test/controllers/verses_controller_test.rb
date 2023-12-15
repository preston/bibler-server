# frozen_string_literal: true

require 'test_helper'

# Author: Preston Lee
class VersesControllerTest < ActionController::TestCase
  setup do
    @bible = Bible.first
    @book = Book.first
    @chapter = 1
    @ordinal = 1
  end

  test 'should get verses for chapter' do
    get :verses, params: { bible: @bible.slug, book: @book.slug, chapter: @chapter, format: :json }
    assert_response :success
    assert_not_nil assigns(:verses)
  end

  test 'should show verse' do
    get :show, params: { bible: @bible.slug, book: @book.slug, chapter: @chapter, ordinal: @ordinal, format: :json }
    assert_not_nil assigns(:verse)
    assert_response :success
  end
end
