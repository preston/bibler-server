# frozen_string_literal: true

require 'json'

module Ollama
  class PromptPolicy
    DEFAULT_MAX_CONTEXT_CHARS = 12_000
    DEFAULT_MAX_ARRAY_ITEMS = 25
    DEFAULT_MAX_STRING_CHARS = 600

    # Canonical Bibler study-assistant rules (aligned with bibler-projects AI rules).
    DEFAULT_STUDY_AI_SYSTEM_PROMPT = <<~PROMPT.strip
      You assist with Christian Bible study tools rooted in accurate translations.
      STRICT RULES:
      - NEVER fabricate scripture, verses, books, chapter numbers, citations, or any biblical content. Only use content supplied from the Bibler database in this conversation.
      - Accuracy is CRITICAL.
      - Strongly adhere to biblical commandments. Avoid interpretations not firmly rooted in citable biblical text from the database.
      - Prioritize correctness over politeness. State what scripture supports according to the provided database text.
      - NEVER change biblical truth to avoid offending anyone. Be polite, but never compromise integrity of biblical adherence for political correctness.
      - If you do not know something from the database context, say so. You may offer careful interpretation only if you clearly label it as interpretation and anchor it in scripture text provided from the database.
      - When suggesting actions, only reference verse locations that appear in DATABASE RESULTS or the study snapshot; do not invent references.
    PROMPT

    SCRIPTURE_POLICY = <<~POLICY.strip
      You are assisting with Christian Bible study tools.
      STRICT RULES:
      - Never fabricate verses, books, chapter numbers, or citations.
      - If a citation is uncertain, state uncertainty clearly.
      - Ground all theological claims in provided scriptural context.
      - Do not present non-biblical claims as scripture.
      - Keep output useful for study leaders and participants.
    POLICY

    def self.system_message
      SCRIPTURE_POLICY
    end

    def self.effective_study_system_prompt(study)
      return DEFAULT_STUDY_AI_SYSTEM_PROMPT unless study&.metadata.is_a?(Hash)

      s = study.metadata['ai_system_prompt']
      s.is_a?(String) && s.present? ? s : DEFAULT_STUDY_AI_SYSTEM_PROMPT
    end

    def self.compose(prompt:, context:)
      context_json = JSON.pretty_generate(normalize_context(context))
      if context_json.length > max_context_chars
        context_json = "#{context_json[0...max_context_chars]}\n... [truncated]"
      end

      <<~PROMPT
        #{SCRIPTURE_POLICY}

        USER REQUEST:
        #{prompt.presence || 'Provide a biblically grounded response from the supplied context.'}

        STUDY CONTEXT JSON:
        #{context_json}
      PROMPT
    end

    def self.normalize_context(value)
      case value
      when Hash
        value.each_with_object({}) do |(key, nested), acc|
          acc[key] = normalize_context(nested)
        end
      when Array
        limited = value.first(max_array_items).map { |item| normalize_context(item) }
        limited << { _truncated_items: value.length - max_array_items } if value.length > max_array_items
        limited
      when String
        value.length > max_string_chars ? "#{value[0...max_string_chars]}... [truncated]" : value
      else
        value
      end
    end

    def self.max_context_chars
      Integer(ENV.fetch('BIBLER_SERVER_OLLAMA_MAX_CONTEXT_CHARS', DEFAULT_MAX_CONTEXT_CHARS))
    rescue ArgumentError
      DEFAULT_MAX_CONTEXT_CHARS
    end

    def self.max_array_items
      Integer(ENV.fetch('BIBLER_SERVER_OLLAMA_MAX_ARRAY_ITEMS', DEFAULT_MAX_ARRAY_ITEMS))
    rescue ArgumentError
      DEFAULT_MAX_ARRAY_ITEMS
    end

    def self.max_string_chars
      Integer(ENV.fetch('BIBLER_SERVER_OLLAMA_MAX_STRING_CHARS', DEFAULT_MAX_STRING_CHARS))
    rescue ArgumentError
      DEFAULT_MAX_STRING_CHARS
    end
  end
end
