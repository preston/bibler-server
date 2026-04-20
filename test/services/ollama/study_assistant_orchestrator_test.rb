# frozen_string_literal: true

require 'test_helper'

module Ollama
  class StudyAssistantOrchestratorTest < ActiveSupport::TestCase
    class FakeChat
      def initialize(outputs)
        @outputs = outputs
      end

      def chat_with_system(**)
        { output: @outputs.shift }
      end
    end

    class FakeChatRecording
      attr_reader :system_messages

      def initialize(outputs)
        @outputs = outputs
        @system_messages = []
      end

      def chat_with_system(system_message:, user_content:, model: nil, **)
        @system_messages << system_message
        { output: @outputs.shift }
      end
    end

    test 'uses distinct system prompts for round a and round b' do
      fake = FakeChatRecording.new(['{"searches":[]}', '{"suggestions":[]}'])
      StudyAssistantOrchestrator.new(
        study: studies(:one),
        user_message: 'help me study',
        model: nil,
        chat_service: fake
      ).call
      assert_equal 2, fake.system_messages.size
      assert_not_equal fake.system_messages[0], fake.system_messages[1]
      assert_includes fake.system_messages[0], 'SEARCH PLANNING'
      assert_includes fake.system_messages[0], 'pg_search'
      refute_includes fake.system_messages[1], 'SEARCH PLANNING'
    end

    test 'preserves suggestion order with order field matching array index' do
      round_b = '{"suggestions":[' \
        '{"id":"a","type":"add_verse","title":"first","summary":"s","payload":{}},' \
        '{"id":"b","type":"add_question","title":"second","summary":"s","payload":{}}' \
        ']}'
      orch = StudyAssistantOrchestrator.new(
        study: studies(:one),
        user_message: 'help me study',
        model: nil,
        chat_service: FakeChat.new([
          '{"searches":[]}',
          round_b
        ])
      )
      result = orch.call
      assert_nil result[:error]
      sugg = result[:suggestions]
      assert_equal 2, sugg.size
      assert_equal 0, sugg[0]['order']
      assert_equal 'first', sugg[0]['title']
      assert_equal 1, sugg[1]['order']
      assert_equal 'second', sugg[1]['title']
    end

    test 'caps suggestions at MAX_SUGGESTIONS' do
      max = Ollama::StudyAssistantOrchestrator::MAX_SUGGESTIONS
      sugg = (0..max).map do |i|
        %({"id":"#{i}","type":"add_verse","title":"t","summary":"s","payload":{}})
      end.join(',')
      round_b = %({"suggestions":[#{sugg}]})
      orch = StudyAssistantOrchestrator.new(
        study: studies(:one),
        user_message: 'help me study',
        model: nil,
        chat_service: FakeChat.new([
          '{"searches":[]}',
          round_b
        ])
      )
      result = orch.call
      assert_nil result[:error]
      assert_equal max, result[:suggestions].size
    end

    test 'normalizes optional duration from suggestion or payload' do
      round_b = '{"suggestions":[' \
        '{"id":"a","type":"add_task","title":"task","summary":"s","duration":"9","payload":{}},' \
        '{"id":"b","type":"add_question","title":"q","summary":"s","payload":{"duration":"0"}},' \
        '{"id":"c","type":"add_commentary","title":"c","summary":"s","duration":"-2","payload":{}}' \
        ']}'
      orch = StudyAssistantOrchestrator.new(
        study: studies(:one),
        user_message: 'help me study',
        model: nil,
        chat_service: FakeChat.new([
          '{"searches":[]}',
          round_b
        ])
      )
      result = orch.call
      assert_nil result[:error]
      assert_equal 9, result[:suggestions][0]['duration']
      assert_equal 0, result[:suggestions][1]['duration']
      assert_nil result[:suggestions][2]['duration']
    end

    test 'returns empty suggestions when round b is not valid json' do
      orch = StudyAssistantOrchestrator.new(
        study: studies(:one),
        user_message: 'x',
        chat_service: FakeChat.new(['{"searches":[]}', 'not json at all'])
      )
      result = orch.call
      assert_equal [], result[:suggestions]
    end

    test 'round b accepts top-level JSON array of suggestion objects' do
      round_b = '[{"id":"a1","type":"add_task","title":"Open","summary":"Read.","payload":{"instruction":"x","task_type":"reading"}}]'
      orch = StudyAssistantOrchestrator.new(
        study: studies(:one),
        user_message: 'help me study',
        chat_service: FakeChat.new(['{"searches":[]}', round_b])
      )
      result = orch.call
      assert_nil result[:error]
      assert_equal 1, result[:suggestions].size
      assert_equal 'add_task', result[:suggestions][0]['type']
    end

    test 'round b unwraps suggestions nested under output' do
      round_b = '{"output":{"suggestions":[{"id":"b1","type":"add_question","title":"Q","summary":"S","payload":{"prompt":"p","question_type":"discussion"}}]}}'
      orch = StudyAssistantOrchestrator.new(
        study: studies(:one),
        user_message: 'help me study',
        chat_service: FakeChat.new(['{"searches":[]}', round_b])
      )
      result = orch.call
      assert_nil result[:error]
      assert_equal 1, result[:suggestions].size
      assert_equal 'add_question', result[:suggestions][0]['type']
    end

    test 'round b prefers non-empty suggestions over empty top-level array when both present' do
      round_b = '{"suggestions":[],"output":{"suggestions":[{"id":"c1","type":"add_task","title":"Break","summary":"Rest.","payload":{"instruction":"Pause","task_type":"reflection"}}]}}'
      orch = StudyAssistantOrchestrator.new(
        study: studies(:one),
        user_message: 'help me study',
        chat_service: FakeChat.new(['{"searches":[]}', round_b])
      )
      result = orch.call
      assert_nil result[:error]
      assert_equal 1, result[:suggestions].size
      assert_equal 'add_task', result[:suggestions][0]['type']
    end

    test 'round b coerces break type to add_task' do
      round_b = '{"suggestions":[{"id":"d1","type":"break","title":"Pause","summary":"Five minutes.","payload":{"instruction":"Break","task_type":"reflection"}}]}'
      orch = StudyAssistantOrchestrator.new(
        study: studies(:one),
        user_message: 'help me study',
        chat_service: FakeChat.new(['{"searches":[]}', round_b])
      )
      result = orch.call
      assert_nil result[:error]
      assert_equal 1, result[:suggestions].size
      assert_equal 'add_task', result[:suggestions][0]['type']
    end

    test 'round b parses double-encoded JSON string payload' do
      inner = '{"suggestions":[{"id":"e1","type":"add_commentary","title":"Note","summary":"S","payload":{"source_type":"manual","title":"t","body":"b"}}]}'
      round_b = inner.to_json
      orch = StudyAssistantOrchestrator.new(
        study: studies(:one),
        user_message: 'help me study',
        chat_service: FakeChat.new(['{"searches":[]}', round_b])
      )
      result = orch.call
      assert_nil result[:error]
      assert_equal 1, result[:suggestions].size
      assert_equal 'add_commentary', result[:suggestions][0]['type']
    end

    test 'returns error when user message blank' do
      orch = StudyAssistantOrchestrator.new(
        study: studies(:one),
        user_message: '   ',
        chat_service: FakeChat.new([])
      )
      result = orch.call
      assert result[:error].present?
    end

    test 'applies fallback lexical searches when round a returns empty searches' do
      orch = StudyAssistantOrchestrator.new(
        study: studies(:one),
        user_message: 'Lorem ipsum lesson plan',
        model: nil,
        chat_service: FakeChat.new([
          '{"searches":[]}',
          '{"suggestions":[]}'
        ])
      )
      result = orch.call
      assert_nil result[:error]
      assert result[:debug][:searches_requested].present?
      assert_operator result[:debug][:verses_returned], :>, 0
    end

    class FakeChatStreaming
      def initialize(outputs)
        @outputs = outputs
      end

      def chat_with_system_stream(system_message:, user_content:, model: nil, on_delta: nil, **)
        out = @outputs.shift
        on_delta&.call(out.to_s)
        { output: out.to_s, model: 'm' }
      end
    end

    test 'emits lifecycle events when streaming and on_event is set' do
      events = []
      orch = StudyAssistantOrchestrator.new(
        study: studies(:one),
        user_message: 'help me study',
        model: nil,
        chat_service: FakeChatStreaming.new([
          '{"searches":[]}',
          '{"suggestions":[]}'
        ]),
        on_event: ->(h) { events << h[:event] },
        stream: true
      )
      result = orch.call
      assert_nil result[:error]
      assert_includes events, 'started'
      assert_includes events, 'plan'
      assert_includes events, 'search_results'
      assert_includes events, 'complete'
    end

    test 'detects user intent for non-English Bible search' do
      assert StudyAssistantOrchestrator.new(
        study: studies(:one),
        user_message: 'What is agape in Greek?'
      ).send(:user_requested_non_english_bible_search?)

      refute StudyAssistantOrchestrator.new(
        study: studies(:one),
        user_message: 'Plan a lesson about love in John'
      ).send(:user_requested_non_english_bible_search?)
    end

    test 'reference_bibles_for_search defaults to English AI Bible only' do
      orch = StudyAssistantOrchestrator.new(
        study: studies(:one),
        user_message: 'lesson about Mary'
      )
      refs = orch.send(:reference_bibles_for_search)
      assert_equal 1, refs.size
      assert_equal bibles(:test1).uuid, refs.first[:uuid]
    end

    test 'reference_bibles_for_search includes AI defaults for original languages when user asks' do
      orch = StudyAssistantOrchestrator.new(
        study: studies(:one),
        user_message: 'Compare the Hebrew word for love with the English translation'
      )
      refs = orch.send(:reference_bibles_for_search)
      uuids = refs.map { |r| r[:uuid] }.sort
      assert_equal [bibles(:test1).uuid, bibles(:test_hebrew_ot).uuid].sort, uuids
    end

    test 'round a user prompt does not embed full Bible table' do
      captured = []
      fake = Class.new do
        def initialize(sink)
          @sink = sink
        end

        def chat_with_system(system_message:, user_content:, **)
          @sink << user_content
          { output: '{"searches":[]}' }
        end
      end
      StudyAssistantOrchestrator.new(
        study: studies(:one),
        user_message: 'lesson on faith',
        chat_service: fake.new(captured)
      ).call
      body = captured.first.to_s
      refute_includes body, '"abbreviation":"TEST2"', 'prompt should not list unrelated Bibles from the full catalog'
    end
  end
end
