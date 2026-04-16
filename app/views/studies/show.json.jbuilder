json.study do
  json.partial! 'studies/study', study: @study, mode: @study_mode
  json.counts do
    json.verses @study.study_verses.count
    json.commentaries @study.study_commentaries.count
    json.questions @study.study_questions.count
    json.tasks @study.study_tasks.count
    json.answers @study.study_answers.count
  end
end
