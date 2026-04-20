# frozen_string_literal: true

require 'test_helper'

# Author: Preston Lee
class StudiesApiTest < ActionDispatch::IntegrationTest
  setup do
    @study = studies(:one)
    @question = study_questions(:one)
    @task = study_tasks(:one)
    @auth_one = { 'Authorization' => "Bearer #{users(:one).api_token}" }
  end

  test 'creates and fetches a study by uuid' do
    post '/studies.json', params: {
      study: {
        title: 'New Study',
        goal: 'Goal',
        visibility: 'private'
      }
    }, headers: @auth_one

    assert_response :created
    created_uuid = JSON.parse(response.body).dig('study', 'uuid')
    assert_not_nil created_uuid

    get "/studies/#{created_uuid}.json", headers: @auth_one
    assert_response :success
    body = JSON.parse(response.body)
    assert_equal 'New Study', body.dig('study', 'title')
  end

  test 'supports mode capability hints' do
    get "/studies/#{@study.uuid}.json", params: { mode: 'leader' }, headers: @auth_one
    assert_response :success
    body = JSON.parse(response.body)
    assert_equal true, body.dig('study', 'capabilities', 'can_edit_structure')
    assert_equal true, body.dig('study', 'capabilities', 'can_reorder_content')
    assert_equal true, body.dig('study', 'capabilities', 'can_delete_study')
  end

  test 'co-leader cannot delete entire study' do
    get "/studies/#{@study.uuid}.json", params: { mode: 'co-leader' }, headers: @auth_one
    assert_response :success
    body = JSON.parse(response.body)
    assert_equal false, body.dig('study', 'capabilities', 'can_delete_study')
  end

  test 'leader can destroy study' do
    delete "/studies/#{@study.uuid}.json", params: { mode: 'leader' }, headers: @auth_one
    assert_response :no_content
  end

  test 'co-leader cannot destroy study' do
    delete "/studies/#{studies(:two).uuid}.json", params: { mode: 'co-leader' }
    assert_response :forbidden
  end

  test 'supports nested questions, answers, and tasks' do
    post "/studies/#{@study.uuid}/questions.json", params: {
      study_question: {
        prompt: 'What does this verse command?',
        question_type: 'discussion'
      }
    }, headers: @auth_one.merge('X-Study-Mode' => 'leader')
    assert_response :created
    question_uuid = JSON.parse(response.body).dig('question', 'uuid')

    post "/studies/#{@study.uuid}/questions/#{question_uuid}/answers.json", params: {
      study_answer: {
        response: 'It calls us to obedience.',
        visibility: 'study',
        author_label: 'Participant'
      }
    }, headers: @auth_one.merge('X-Study-Mode' => 'participant')
    assert_response :created

    post "/studies/#{@study.uuid}/tasks.json", params: {
      study_task: {
        instruction: 'Read the chapter and report one insight.',
        task_type: 'reading',
        status: 'open'
      }
    }, headers: @auth_one.merge('X-Study-Mode' => 'leader')
    assert_response :created
  end

  test 'reorders questions and tasks by uuid sequence' do
    q2 = StudyQuestion.create!(study: @study, prompt: 'Second prompt', question_type: 'discussion', position: 1)
    post "/studies/#{@study.uuid}/questions/reorder.json",
         params: { ordered_uuids: [q2.uuid, @question.uuid], mode: 'leader' },
         headers: @auth_one.merge('X-Study-Mode' => 'leader')
    assert_response :success
    assert_equal [q2.uuid, @question.uuid], @study.study_questions.ordered.pluck(:uuid).first(2)

    t2 = StudyTask.create!(study: @study, instruction: 'Second task', task_type: 'reading', status: 'open', position: 1)
    post "/studies/#{@study.uuid}/tasks/reorder.json",
         params: { ordered_uuids: [t2.uuid, @task.uuid], mode: 'leader' },
         headers: @auth_one.merge('X-Study-Mode' => 'leader')
    assert_response :success
    assert_equal [t2.uuid, @task.uuid], @study.study_tasks.ordered.pluck(:uuid).first(2)
  end

  test 'supports study plan items CRUD and reorder' do
    post "/studies/#{@study.uuid}/plan_items.json", params: {
      study_plan_item: {
        title: 'Opening',
        item_type: 'custom',
        notes: 'Welcome everyone',
        metadata: { anchor: 'intro' }
      }
    }, headers: @auth_one.merge('X-Study-Mode' => 'leader')
    assert_response :created
    item_uuid = JSON.parse(response.body).dig('plan_item', 'uuid')
    assert_equal 5, JSON.parse(response.body).dig('plan_item', 'duration')

    get "/studies/#{@study.uuid}/plan_items.json", headers: @auth_one
    assert_response :success
    assert_includes JSON.parse(response.body).fetch('plan_items').map { |i| i['uuid'] }, item_uuid

    patch "/studies/#{@study.uuid}/plan_items/#{item_uuid}.json", params: {
      mode: 'leader',
      study_plan_item: { title: 'Opening Prayer' }
    }, headers: @auth_one.merge('X-Study-Mode' => 'leader')
    assert_response :success

    post "/studies/#{@study.uuid}/plan_items/reorder.json",
         params: { ordered_uuids: [item_uuid], mode: 'leader' },
         headers: @auth_one.merge('X-Study-Mode' => 'leader')
    assert_response :success
  end

  test 'accepts duration on plan items and serializes zero as unspecified' do
    post "/studies/#{@study.uuid}/plan_items.json", params: {
      study_plan_item: {
        title: 'Timed',
        item_type: 'task',
        notes: '',
        duration: 12
      }
    }, headers: @auth_one.merge('X-Study-Mode' => 'leader')
    assert_response :created
    item_uuid = JSON.parse(response.body).dig('plan_item', 'uuid')
    assert_equal 12, JSON.parse(response.body).dig('plan_item', 'duration')

    patch "/studies/#{@study.uuid}/plan_items/#{item_uuid}.json", params: {
      mode: 'leader',
      study_plan_item: { duration: 0 }
    }, headers: @auth_one.merge('X-Study-Mode' => 'leader')
    assert_response :success
    assert_nil JSON.parse(response.body).dig('plan_item', 'duration')
  end

  test 'plan item user state persists per authenticated user' do
    post "/studies/#{@study.uuid}/plan_items.json", params: {
      study_plan_item: { title: 'State step', item_type: 'custom', notes: '' }
    }, headers: @auth_one.merge('X-Study-Mode' => 'leader')
    assert_response :created
    item_uuid = JSON.parse(response.body).dig('plan_item', 'uuid')

    patch "/studies/#{@study.uuid}/plan_items/#{item_uuid}/state.json",
          params: { status: 'revisit' },
          headers: @auth_one.merge('X-Study-Mode' => 'participant')
    assert_response :success
    assert_equal 'revisit', JSON.parse(response.body).dig('plan_item', 'my_status')

    get "/studies/#{@study.uuid}/plan_items.json", headers: @auth_one
    assert_response :success
    row = JSON.parse(response.body).fetch('plan_items').find { |i| i['uuid'] == item_uuid }
    assert_equal 'revisit', row['my_status']
  end

  test 'plan item state requires authentication' do
    study = studies(:two)
    post "/studies/#{study.uuid}/plan_items.json", params: {
      study_plan_item: { title: 'Auth step', item_type: 'custom', notes: '' }
    }, headers: @auth_one.merge('X-Study-Mode' => 'leader')
    item_uuid = JSON.parse(response.body).dig('plan_item', 'uuid')

    patch "/studies/#{study.uuid}/plan_items/#{item_uuid}/state.json", params: { status: 'complete' }
    assert_response :unauthorized
  end

  test 'routes still resolve existing verse lookup endpoint' do
    verse = Verse.first
    get "/#{verse.bible.uuid}/#{verse.book.uuid}/#{verse.chapter}/#{verse.ordinal}.json"
    assert_response :success
  end

  test 'supports studies index sorting and pagination metadata' do
    get '/studies.json', params: { q: 'Study', sort: 'title', direction: 'asc', page: 1, per_page: 1 }
    assert_response :success
    body = JSON.parse(response.body)
    assert body['meta'].present?
    assert_equal 1, body.dig('meta', 'page')
    assert_equal 1, body.dig('meta', 'per_page')
    assert_equal 'title', body.dig('meta', 'sort')
    assert_equal 'asc', body.dig('meta', 'direction')
    assert_equal 1, body.fetch('studies').length
  end

  test 'includes total_duration_minutes in studies index and excludes zero durations' do
    study = studies(:one)
    StudyPlanItem.create!(study: study, title: 'A', item_type: 'verse', notes: '', metadata: {}, position: 900, duration: 3)
    StudyPlanItem.create!(study: study, title: 'B', item_type: 'task', notes: '', metadata: {}, position: 901, duration: 0)

    get '/studies.json', params: { scope: 'owned' }, headers: @auth_one
    assert_response :success
    row = JSON.parse(response.body).fetch('studies').find { |s| s['uuid'] == study.uuid }
    assert_not_nil row
    assert_equal 3, row['total_duration_minutes']
  end

  test 'strips selected_bible_uuids from study metadata on update' do
    uuids = Bible.limit(2).pluck(:uuid)
    patch "/studies/#{@study.uuid}.json", params: {
      mode: 'leader',
      study: { metadata: { selected_bible_uuids: uuids, keep_me: 'yes' } }
    }, headers: @auth_one.merge('X-Study-Mode' => 'leader')
    assert_response :success

    @study.reload
    assert_equal 'yes', @study.metadata['keep_me']
    refute @study.metadata.key?('selected_bible_uuids')
  end
end
