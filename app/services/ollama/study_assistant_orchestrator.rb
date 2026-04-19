# frozen_string_literal: true

module Ollama
  class StudyAssistantOrchestrator
    MAX_SUGGESTIONS = 16
    MAX_SEARCH_ITEMS = 20
    SUGGESTION_TYPES = %w[add_verse add_commentary add_question add_task].freeze

    def initialize(study:, user_message:, model: nil, chat_service: nil, on_event: nil, stream: false, reference_bible_uuids: nil)
      @study = study
      @user_message = user_message.to_s.strip
      @model = model
      @chat = chat_service || ChatService.new
      @on_event = on_event
      @stream = stream
      @reference_bible_uuids = Array(reference_bible_uuids).map(&:to_s).reject(&:blank?)
    end

    def call
      return { error: 'User message is blank.' } if @user_message.blank?

      emit('started', {})
      system_search = Prompts::StudyAssistant.search_system_prompt
      system_suggestions = Prompts::StudyAssistant.suggestions_system_prompt
      snapshot = build_study_snapshot
      catalog = build_bibles_catalog
      selected_refs = reference_bibles_for_search

      emit('status', { phase: 'planning', message: 'Planning database searches…' })
      round_a_content = Prompts::StudyAssistant.round_a_user_content(
        user_message: @user_message,
        snapshot: snapshot,
        catalog: catalog,
        selected_refs: selected_refs,
        max_search_items: MAX_SEARCH_ITEMS
      )
      a_resp = run_llm_round(system: system_search, user_content: round_a_content, round: 'a')
      return emit_error_and_return(a_resp) if ChatService.response_error?(a_resp)

      plan = ResponseJson.parse_object(a_resp[:output].to_s) || {}
      searches = normalize_searches(plan['searches'] || plan[:searches])
      searches = constrain_searches_to_reference_bibles(searches, selected_refs)
      emit('plan', { searches: searches_summary_for_ui(searches) })

      emit('status', { phase: 'searching', message: 'Searching your Bibles…' })
      search_result = BibleStudySearchService.call(searches: searches)
      emit('search_results', search_results_payload(search_result))

      emit('status', { phase: 'drafting', message: 'Drafting suggestions…' })
      round_b_content = Prompts::StudyAssistant.round_b_user_content(
        user_message: @user_message,
        snapshot: snapshot,
        catalog: catalog,
        selected_refs: selected_refs,
        search_result: search_result,
        max_suggestions: MAX_SUGGESTIONS,
        suggestion_types: SUGGESTION_TYPES
      )
      b_resp = run_llm_round(system: system_suggestions, user_content: round_b_content, round: 'b')
      return emit_error_and_return(b_resp) if ChatService.response_error?(b_resp)

      parsed = ResponseJson.parse_object(b_resp[:output].to_s) || {}
      suggestions = normalize_suggestions(parsed['suggestions'] || parsed[:suggestions])

      debug = build_debug_payload(searches: searches, search_result: search_result, selected_refs: selected_refs)
      payload = { suggestions: suggestions, debug: debug }
      emit('complete', payload)
      payload
    end

    private

    def emit_error_and_return(resp)
      msg = resp[:error].presence || resp['error'].presence || 'Unknown error'
      hint = resp[:hint].presence || resp['hint'].presence
      emit('error', { error: msg.to_s, hint: hint }.compact)
      resp
    end

    def emit(event, data)
      @on_event&.call({ event: event, data: data })
    end

    def run_llm_round(system:, user_content:, round:)
      if @stream
        @chat.chat_with_system_stream(
          system_message: system,
          user_content: user_content,
          model: @model,
          on_delta: proc { |accumulated| emit('llm_delta', { round: round, content: accumulated }) }
        )
      else
        @chat.chat_with_system(system_message: system, user_content: user_content, model: @model)
      end
    end

    def searches_summary_for_ui(searches)
      searches.map do |s|
        s = s.symbolize_keys
        bible = BibleStudySearchService.resolve_bible(s[:bible_uuid])
        {
          bible_uuid: bible&.uuid,
          bible_name: bible&.name,
          query_preview: s[:text].to_s.truncate(100),
          limit: s[:limit]
        }
      end
    end

    def search_results_payload(search_result)
      verses = search_result[:verses]
      errors = Array(search_result[:errors]).map(&:to_s)
      by_uuid = verses.group_by { |v| v[:bible_uuid].to_s }
      by_bible = by_uuid.map do |uuid, rows|
        name = Bible.find_by(uuid: uuid)&.name
        { bible_uuid: uuid, bible_name: name, count: rows.size }
      end
      {
        verse_count: verses.size,
        by_bible: by_bible,
        errors: errors
      }
    end

    def build_study_snapshot
      {
        study: @study.slice(:uuid, :title, :goal, :visibility).merge(selected_bible_uuids: @study.selected_bible_uuids),
        verses: @study.study_verses.ordered.map { |c| c.slice(:uuid, :bible_uuid, :book_uuid, :chapter, :ordinal, :verse_text, :note) },
        commentaries: @study.study_commentaries.ordered.map { |c| c.slice(:uuid, :source_type, :title, :body) },
        questions: @study.study_questions.ordered.map do |q|
          {
            uuid: q.uuid,
            prompt: q.prompt,
            question_type: q.question_type,
            guidance_notes: q.guidance_notes,
            verse_anchor: q.verse_anchor,
            answers: q.study_answers.order(created_at: :desc).limit(8).map { |a| a.slice(:response, :author_label, :visibility) }
          }
        end,
        tasks: @study.study_tasks.ordered.map { |t| t.slice(:uuid, :instruction, :task_type, :status, :assignee_label) }
      }
    end

    def build_bibles_catalog
      Bible.order(:id).map do |b|
        b.slice(:id, :uuid, :name, :abbreviation, :language, :license, :created_at, :updated_at).symbolize_keys
      end
    end

    def selected_reference_bibles
      pool = build_bibles_catalog
      by_uuid = pool.index_by { |b| b[:uuid] }
      selected = if @reference_bible_uuids.any?
                   @reference_bible_uuids.filter_map { |uuid| by_uuid[uuid] }
                 else
                   Bible.default_ai_reference_bibles.values.compact.map { |b| by_uuid[b['uuid']] || by_uuid[b[:uuid]] }.compact
                 end
      selected.uniq { |b| b[:uuid] }
    end

    # Bibles allowed for Round-A search planning: UI reference list intersected with study metadata when set.
    def reference_bibles_for_search
      refs = selected_reference_bibles
      study_uuids = @study.selected_bible_uuids
      return refs if study_uuids.blank?

      filtered = refs.select { |b| study_uuids.include?(b[:uuid].to_s) }
      if filtered.empty?
        Rails.logger.warn('[StudyAssistant] study selected_bible_uuids did not match any reference Bible; using reference list as-is')
        refs
      else
        filtered
      end
    end

    def constrain_searches_to_reference_bibles(searches, allowed_ref_rows)
      allowed_uuids = allowed_ref_rows.map { |b| b[:uuid].to_s }.uniq
      return [] if allowed_uuids.empty?

      searches.filter_map do |s|
        s = s.symbolize_keys
        text = s[:text].to_s.strip
        next nil if text.blank?

        uuid = s[:bible_uuid].to_s.presence
        if uuid.blank?
          if allowed_uuids.length == 1
            uuid = allowed_uuids.first
            Rails.logger.info('[StudyAssistant] search omitted bible_uuid; defaulting to sole reference Bible')
          else
            Rails.logger.warn('[StudyAssistant] dropping search: bible_uuid missing with multiple reference Bibles')
            next nil
          end
        elsif allowed_uuids.exclude?(uuid)
          Rails.logger.warn("[StudyAssistant] dropping search: bible_uuid #{uuid} not in allowed reference set")
          next nil
        end

        row = { text: text, bible_uuid: uuid }
        row[:limit] = s[:limit] if s[:limit].present?
        row
      end
    end

    def normalize_searches(list)
      return [] unless list.is_a?(Array)

      list.first(MAX_SEARCH_ITEMS).filter_map do |item|
        next unless item.is_a?(Hash)

        h = item.symbolize_keys
        text = h[:text].to_s.strip
        next if text.blank?

        row = { text: text }
        row[:bible_uuid] = h[:bible_uuid].to_s.presence if h[:bible_uuid].present?
        row[:limit] = h[:limit] if h[:limit].present?
        row
      end
    end

    def normalize_suggestions(list)
      return [] unless list.is_a?(Array)

      out = []
      list.each do |item|
        break if out.length >= MAX_SUGGESTIONS

        next unless item.is_a?(Hash)

        h = item.stringify_keys
        type = h['type'].to_s
        next unless SUGGESTION_TYPES.include?(type)

        payload = h['payload']
        payload = payload.is_a?(Hash) ? payload : {}

        out << {
          'order' => out.length,
          'id' => h['id'].presence || SecureRandom.uuid,
          'type' => type,
          'title' => h['title'].to_s.truncate(200),
          'summary' => h['summary'].to_s.truncate(2000),
          'payload' => payload,
          'duration' => normalize_duration(h['duration'] || payload['duration'])
        }
      end

      Rails.logger.info("[StudyAssistant] truncated suggestions from #{list.length} to #{MAX_SUGGESTIONS}") if list.length > MAX_SUGGESTIONS

      out
    end

    def build_debug_payload(searches:, search_result:, selected_refs:)
      {
        searches_requested: searches,
        search_errors: search_result[:errors],
        verses_returned: search_result[:verses].size,
        reference_bibles: selected_refs
      }
    end

    def normalize_duration(raw)
      return nil if raw.nil?

      value = Integer(raw, exception: false)
      return nil if value.nil? || value.negative?

      value
    end
  end
end
