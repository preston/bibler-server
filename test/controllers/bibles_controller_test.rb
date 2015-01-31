require 'test_helper'

class BiblesControllerTest < ActionController::TestCase
  setup do
    @bible = bibles(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:bibles)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create bible" do
    assert_difference('Bible.count') do
      post :create, bible: { abbreviation: @bible.abbreviation, name: @bible.name }
    end

    assert_redirected_to bible_path(assigns(:bible))
  end

  test "should show bible" do
    get :show, id: @bible
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @bible
    assert_response :success
  end

  test "should update bible" do
    patch :update, id: @bible, bible: { abbreviation: @bible.abbreviation, name: @bible.name }
    assert_redirected_to bible_path(assigns(:bible))
  end

  test "should destroy bible" do
    assert_difference('Bible.count', -1) do
      delete :destroy, id: @bible
    end

    assert_redirected_to bibles_path
  end
end
