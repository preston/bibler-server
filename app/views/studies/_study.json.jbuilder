json.extract! study, :uuid, :title, :goal, :visibility, :metadata, :created_at, :updated_at
json.total_duration_minutes (defined?(total_duration_minutes) ? total_duration_minutes.to_i : 0)
if study.owner
  json.owner do
    json.id study.owner.id
    json.username study.owner.username
    json.name study.owner.name
  end
end
json.ai_system_prompt_effective Ollama::PromptPolicy.effective_study_system_prompt(study)
json.ai_system_prompt_default Ollama::PromptPolicy::DEFAULT_STUDY_AI_SYSTEM_PROMPT
json.ai_system_prompt_customized study.metadata.is_a?(Hash) && study.metadata['ai_system_prompt'].to_s.present?
json.ai_default_reference_bibles Bible.default_ai_reference_bibles
json.selected_bible_uuids study.selected_bible_uuids
json.capabilities study.capabilities_for(mode)
json.paths do
  json.self study_path(study.uuid, format: :json)
  json.verses study_study_verses_path(study.uuid, format: :json)
  json.commentaries study_study_commentaries_path(study.uuid, format: :json)
  json.questions study_study_questions_path(study.uuid, format: :json)
  json.tasks study_study_tasks_path(study.uuid, format: :json)
  json.plan_items study_study_plan_items_path(study.uuid, format: :json)
end
