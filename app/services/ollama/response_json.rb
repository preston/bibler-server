# frozen_string_literal: true

module Ollama
  module ResponseJson
    def self.parse_object(text)
      return nil if text.blank?

      stripped = text.to_s.strip
      if stripped.include?('```')
        stripped = stripped.sub(/\A```(?:json)?\s*/mi, '')
        stripped = stripped.sub(/\s*```\z/m, '')
        stripped = stripped.strip
      end

      JSON.parse(stripped)
    rescue JSON::ParserError
      i = stripped.index('{')
      j = stripped.rindex('}')
      return nil if i.nil? || j.nil? || j <= i

      JSON.parse(stripped[i..j])
    rescue JSON::ParserError
      nil
    end
  end
end
