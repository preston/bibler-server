# frozen_string_literal: true

require 'json'

module Ollama
  module Prompts
    # System prompts and user message templates for {StudyAssistantOrchestrator}.
    module StudyAssistant
      module_function

      def search_system_prompt
        <<~PROMPT.strip
          #{Core::CORE_AI_RULES}

          SEARCH PLANNING (ROUND 1) — ADDITIONAL RULES:
          - You output ONLY the JSON object described in the user message (no markdown).
          - Each search "text" must be a few simple KEYWORDS or a very SHORT PHRASE suitable for full-text search (PostgreSQL/pg_search) on verse text in that Bible. Do NOT use long questions or conversational sentences as search text.
          - Each "bible_uuid" MUST appear in REFERENCE_BIBLES in the user message. Do not include searches for Bibles outside that list.
          - Match the language of search terms to the Bible's language (see BIBLES_CATALOG / REFERENCE_BIBLES). For example, use English terms for English Bibles, Hebrew terms for Hebrew text, etc.
          - This is lexical/SQL search, not semantic retrieval: prefer distinctive words likely to appear verbatim in the translation.
        PROMPT
      end

      def suggestions_system_prompt
        Core::CORE_AI_RULES
      end

      def round_a_user_content(user_message:, snapshot:, catalog:, selected_refs:, max_search_items:)
        <<~PROMPT
          ROUND 1 — SEARCH PLAN (JSON ONLY)

          Output a single JSON object and nothing else (no markdown fences, no commentary).
          Shape:
          {"searches":[{"bible_uuid":"...","text":"search phrase","limit":10}]}

          Rules:
          - Every bible_uuid MUST be listed in REFERENCE_BIBLES below (the study's reference/selected Bibles only — not the full catalog).
          - At most #{max_search_items} search objects.
          - Each limit must be <= 25.
          - Each "text" must be SHORT: a few keywords or a brief phrase that will match verse text via PostgreSQL full-text search (pg_search). Use the language of that Bible's translation. Do NOT use long natural-language questions.
          - This is SQL-backed keyword search, not a semantic/embedding search.

          USER_MESSAGE:
          #{user_message}

          STUDY_SNAPSHOT:
          #{JSON.pretty_generate(snapshot)}

          BIBLES_CATALOG:
          #{JSON.pretty_generate(catalog)}

          REFERENCE_BIBLES:
          #{JSON.pretty_generate(selected_refs)}
        PROMPT
      end

      def round_b_user_content(
        user_message:,
        snapshot:,
        catalog:,
        selected_refs:,
        search_result:,
        max_suggestions:,
        suggestion_types:
      )
        <<~PROMPT
          ROUND 2 — SUGGESTIONS (JSON ONLY)

          Output a single JSON object and nothing else (no markdown fences, no commentary).
          Shape:
          {"suggestions":[{"id":"stable-id","type":"add_verse","title":"short title","summary":"why this helps","payload":{}}]}

          Rules:
          - At most #{max_suggestions} suggestions.
          - type must be one of: #{Array(suggestion_types).join(', ')}.
          - Optional duration: include duration as an integer minutes estimate >= 0. Use 0 only when intentionally unspecified.
          - For add_verse payload include: bible_uuid, book_uuid, chapter (number), ordinal (number), optional note — only for verses that appear in DATABASE_RESULTS or STUDY_SNAPSHOT.verses.
          - For add_commentary: source_type (manual|ai), title, body, optional prompt, optional duration.
          - For add_question: prompt, question_type (discussion|observation|interpretation|application), optional guidance_notes, optional duration.
          - For add_task: instruction, task_type (discussion|reading|prayer|memorization|reflection), optional assignee_label, optional duration.
          - Never invent verse text; summaries may paraphrase only what DATABASE_RESULTS contain.
          - Each "summary" is stored as the plan step's notes in the UI: aim for about one sentence up to two short paragraphs (not only a title or a single short phrase unless that truly suffices); stay grounded in DATABASE_RESULTS and STUDY_SNAPSHOT.
          - Order suggestions by priority: the first suggestion in the array is the most important; preserve that order in the JSON array.

          USER_MESSAGE:
          #{user_message}

          STUDY_SNAPSHOT:
          #{JSON.pretty_generate(snapshot)}

          BIBLES_CATALOG:
          #{JSON.pretty_generate(catalog)}

          REFERENCE_BIBLES:
          #{JSON.pretty_generate(selected_refs)}

          DATABASE_RESULTS:
          #{JSON.pretty_generate(verses: search_result[:verses], errors: search_result[:errors])}
        PROMPT
      end
    end
  end
end
