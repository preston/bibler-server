# frozen_string_literal: true

require 'test_helper'

# Author: Preston Lee
class AiApiTest < ActionDispatch::IntegrationTest
  setup do
    @study = studies(:one)
    @auth_one = { 'Authorization' => "Bearer #{users(:one).api_token}" }
  end

  test 'health reports unconfigured when ollama url missing' do
    previous = ENV['BIBLER_SERVER_OLLAMA_URL']
    ENV['BIBLER_SERVER_OLLAMA_URL'] = nil
    get '/ai/health'
    assert_response :success
    body = JSON.parse(response.body)
    assert_equal 'unconfigured', body['status']
  ensure
    ENV['BIBLER_SERVER_OLLAMA_URL'] = previous
  end

  test 'chat returns service error when ollama url missing' do
    previous = ENV['BIBLER_SERVER_OLLAMA_URL']
    ENV['BIBLER_SERVER_OLLAMA_URL'] = nil
    post '/ai/chat', params: { prompt: 'test prompt' }
    assert_response :unprocessable_entity
    body = JSON.parse(response.body)
    assert_match(/BIBLER_SERVER_OLLAMA_URL/, body['error'])
  ensure
    ENV['BIBLER_SERVER_OLLAMA_URL'] = previous
  end

  test 'study ai route returns structured error when unconfigured' do
    previous = ENV['BIBLER_SERVER_OLLAMA_URL']
    ENV['BIBLER_SERVER_OLLAMA_URL'] = nil
    post "/studies/#{@study.uuid}/ai/summarize", params: { prompt: 'summarize' }, headers: @auth_one.merge('X-Study-Mode' => 'leader')
    assert_response :unprocessable_entity
    body = JSON.parse(response.body)
    assert body['error'].present?
  ensure
    ENV['BIBLER_SERVER_OLLAMA_URL'] = previous
  end
end
