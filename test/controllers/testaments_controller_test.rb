require 'test_helper'

class TestamentsControllerTest < ActionController::TestCase
  setup do
    @testament = Testament.where(slug: :new).first
  end

  test "should get index" do
    get :index, format: :json
    assert_response :success
    assert_not_nil assigns(:testaments)
  end

  test "should show testament" do
    get :show, id: @testament, format: :json
    assert_response :success
  end

end
