# frozen_string_literal: true

require 'test_helper'

# Author: Preston Lee
class BiblesControllerTest < ActionController::TestCase
  setup do
    @bible = Bible.first
  end

  test 'should get index' do
    get :index, format: :json
    assert_response :success
    assert_not_nil assigns(:bibles)
  end

  test 'should show bible' do
    get :show, params: { id: @bible.slug, format: :json }
    assert_not_nil assigns(:bible)
    assert_response :success
  end
end
