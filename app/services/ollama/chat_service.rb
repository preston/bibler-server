# frozen_string_literal: true

module Ollama
  class ChatService
    def initialize(client: Ollama::Client.new)
      @client = client
    end

    # Ollama JSON uses string keys; our synthetic errors may use symbols.
    def self.response_error?(response)
      response.is_a?(Hash) && (response[:error].present? || response['error'].present?)
    end

    def generate(prompt:, context:, model: nil, system_message: nil)
      final_prompt = PromptPolicy.compose(prompt: prompt, context: context)
      system = system_message.presence || PromptPolicy.system_message
      response = @client.chat(
        model: model,
        messages: [
          { role: 'system', content: system },
          { role: 'user', content: final_prompt }
        ]
      )

      return response if self.class.response_error?(response)

      {
        model: response['model'],
        output: response.dig('message', 'content'),
        raw: response
      }
    end

    # Raw user message (no PromptPolicy.compose wrapper). Used by study assistant orchestration.
    def chat_with_system(system_message:, user_content:, model: nil)
      response = @client.chat(
        model: model,
        messages: [
          { role: 'system', content: system_message },
          { role: 'user', content: user_content }
        ]
      )

      return response if self.class.response_error?(response)

      {
        model: response['model'],
        output: response.dig('message', 'content'),
        raw: response
      }
    end

    # Streaming chat; yields accumulated text via on_delta for each Ollama chunk.
    def chat_with_system_stream(system_message:, user_content:, model: nil, on_delta: nil)
      accumulated = +''
      result = @client.chat_stream(
        model: model,
        messages: [
          { role: 'system', content: system_message },
          { role: 'user', content: user_content }
        ]
      ) do |obj|
        delta = obj.dig('message', 'content').to_s
        next if delta.blank?

        accumulated << delta
        on_delta&.call(accumulated)
      end

      return result if self.class.response_error?(result)

      {
        model: result['model'],
        output: accumulated,
        raw: result
      }
    end
  end
end
