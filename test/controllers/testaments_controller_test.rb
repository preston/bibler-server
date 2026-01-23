# frozen_string_literal: true

require 'test_helper'

# Author: Preston Lee
class TestamentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @testament = Testament.where(slug: :new).first
  end

  test 'should get index' do
    get '/testaments.json'
    assert_response :success
    json = JSON.parse(response.body)
    assert_kind_of Array, json
    assert_operator json.length, :>, 0
  end

  test 'should show testament' do
    get "/testaments/#{@testament.id}.json"
    assert_response :success
    json = JSON.parse(response.body)
    assert_equal @testament.slug, json['slug']
    assert_equal @testament.name, json['name']
  end
end
