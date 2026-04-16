# frozen_string_literal: true

# Author: Preston Lee
module Studies
  class AiController < ApplicationController
    include ActionController::Live
    include StudyContext
    MAX_ASSISTANT_STREAM_SECONDS = 120

    def generate_commentary
      prompt_context = {
        study: @study.slice(:uuid, :title, :goal).merge(selected_bible_uuids: @study.selected_bible_uuids),
        verses: @study.study_verses.ordered.limit(30).map { |sv| sv.slice(:bible_uuid, :book_uuid, :chapter, :ordinal, :verse_text, :note) },
        user_instruction: params[:instruction].to_s
      }

      result = Ollama::ChatService.new.generate(
        prompt: params[:prompt].to_s,
        context: prompt_context,
        model: params[:model]
      )
      render json: result, status: result[:error].present? ? :unprocessable_entity : :ok
    end

    def summarize
      prompt_context = {
        study: @study.slice(:uuid, :title, :goal),
        commentaries: @study.study_commentaries.ordered.limit(20).map { |c| c.slice(:title, :body, :source_type) },
        questions: @study.study_questions.ordered.limit(20).map { |q| q.slice(:prompt, :question_type) }
      }

      result = Ollama::ChatService.new.generate(
        prompt: params[:prompt].presence || 'Provide a concise biblical summary of this study session.',
        context: prompt_context,
        model: params[:model]
      )
      render json: result, status: result[:error].present? ? :unprocessable_entity : :ok
    end

    def generate_questions
      prompt_context = {
        study: @study.slice(:uuid, :title, :goal),
        verses: @study.study_verses.ordered.limit(40).map { |sv| sv.slice(:bible_uuid, :book_uuid, :chapter, :ordinal, :verse_text) }
      }
      result = Ollama::ChatService.new.generate(
        prompt: params[:prompt].presence || 'Generate discussion questions anchored in scripture references from the provided study verses.',
        context: prompt_context,
        model: params[:model]
      )
      render json: result, status: result[:error].present? ? :unprocessable_entity : :ok
    end

    def assistant
      if assistant_stream_requested?
        assistant_as_sse
      else
        result = Ollama::StudyAssistantOrchestrator.new(
          study: @study,
          user_message: params[:message].to_s,
          model: params[:model],
          stream: false,
          reference_bible_uuids: params[:reference_bible_uuids]
        ).call

        status = Ollama::ChatService.response_error?(result) ? :unprocessable_entity : :ok
        render json: result, status: status
      end
    end

    private

    def assistant_stream_requested?
      return true if params[:stream].to_s.in?(%w[1 true yes])
      return true if request.get_header('HTTP_ACCEPT').to_s.include?('text/event-stream')

      false
    end

    def assistant_as_sse
      response.headers['Content-Type'] = 'text/event-stream'
      response.headers['Cache-Control'] = 'no-cache'
      response.headers['Connection'] = 'keep-alive'
      response.headers['X-Accel-Buffering'] = 'no'

      stream_started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      stream_closed = false
      writer = lambda do |h|
        if !stream_closed && (Process.clock_gettime(Process::CLOCK_MONOTONIC) - stream_started_at) >= MAX_ASSISTANT_STREAM_SECONDS
          stream_closed = true
          response.stream.write("event: error\ndata: #{ { error: 'Assistant stream timed out.' }.to_json }\n\n")
          raise ActionController::Live::ClientDisconnected
        end
        name = h[:event].presence || 'message'
        response.stream.write("event: #{name}\ndata: #{h[:data].to_json}\n\n")
      end

      begin
        Rails.logger.info("[StudyAssistant SSE] stream_started study_uuid=#{@study.uuid}")
        Ollama::StudyAssistantOrchestrator.new(
          study: @study,
          user_message: params[:message].to_s,
          model: params[:model],
          stream: true,
          reference_bible_uuids: params[:reference_bible_uuids],
          on_event: writer
        ).call
      rescue ActionController::Live::ClientDisconnected
        nil
      rescue StandardError => e
        Rails.logger.error("[StudyAssistant SSE] #{e.class}: #{e.message}\n#{e.backtrace&.first(5)&.join("\n")}")
        writer.call({ event: 'error', data: { error: e.message } })
      ensure
        elapsed_ms = ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - stream_started_at) * 1000).round
        Rails.logger.info("[StudyAssistant SSE] stream_closed study_uuid=#{@study.uuid} elapsed_ms=#{elapsed_ms}")
        response.stream.close
      end
    end
  end
end
