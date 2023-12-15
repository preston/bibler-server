# frozen_string_literal: true

require 'test_helper'

# Author: Preston Lee
class TestamentsControllerTest < ActionController::TestCase
  setup do
    @testament = Testament.where(slug: :new).first
  end

  test 'should get index' do
    get :index, format: :json
    assert_response :success
    assert_not_nil assigns(:testaments)
  end

  test 'should show testament' do
    get :show, params: { id: @testament, format: :json }
    assert_response :success
  end
end
