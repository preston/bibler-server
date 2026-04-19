# frozen_string_literal: true

# Author: Preston Lee
class StudiesController < ApplicationController
  SORTABLE_COLUMNS = {
    'title' => 'title',
    'visibility' => 'visibility',
    'created_at' => 'created_at',
    'updated_at' => 'updated_at'
  }.freeze
  DEFAULT_PER_PAGE = 25
  MAX_PER_PAGE = 100

  before_action :set_study, only: %i[show update destroy]

  def index
    if params[:scope].to_s == 'owned'
      require_current_user!
      return if performed?
    end

    scoped = index_scope
    q = params[:q].to_s.strip
    scoped = scoped.where('title ILIKE :q OR goal ILIKE :q', q: "%#{q}%") if q.present?

    sort_col = SORTABLE_COLUMNS.fetch(params[:sort].to_s, 'updated_at')
    dir = normalized_direction
    scoped = scoped.order(sort_col => dir)

    page = normalized_page
    per_page = clamped_per_page
    total_count = scoped.count
    total_pages = (total_count.to_f / per_page).ceil
    offset = (page - 1) * per_page

    @studies = scoped.includes(:owner).offset(offset).limit(per_page)
    @studies.each { |study| authorize! :read, study }
    @study_total_duration_by_id = study_total_duration_by_id(@studies)
    @meta = {
      page: page,
      per_page: per_page,
      total_count: total_count,
      total_pages: total_pages,
      sort: sort_col,
      direction: dir,
      q: q
    }
    @study_mode = requested_study_mode
  end

  def show
    authorize! :read, @study
    @study_mode = requested_study_mode
  end

  def create
    require_current_user!
    return if performed?

    authorize! :create, Study
    @study = Study.new(study_params)
    @study.owner = current_user
    @study_mode = requested_study_mode
    if @study.save
      render :show, status: :created
    else
      render json: { errors: @study.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    authorize! :update, @study
    @study_mode = requested_study_mode
    if @study.update(study_params)
      render :show, status: :ok
    else
      render json: { errors: @study.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    authorize! :destroy, @study
    @study.destroy
    head :no_content
  end

  private

  def index_scope
    case params[:scope].to_s
    when 'owned'
      Study.where(owner_id: current_user.id)
    else
      Study.where(visibility: 'public')
    end
  end

  def set_study
    @study = Study.includes(:owner).find_by(uuid: params[:uuid])
    return if @study

    render json: { error: 'Study not found.' }, status: :not_found
  end

  def normalized_direction
    params[:direction].to_s.casecmp('asc').zero? ? :asc : :desc
  end

  def clamped_per_page
    raw = params[:per_page].to_i
    raw = DEFAULT_PER_PAGE if raw <= 0
    [raw, MAX_PER_PAGE].min
  end

  def normalized_page
    raw = params[:page].to_i
    raw < 1 ? 1 : raw
  end

  def study_params
    permitted = params.require(:study).permit(:title, :goal, :visibility)
    if params[:study].key?(:metadata)
      raw = params[:study][:metadata]
      incoming = case raw
                 when ActionController::Parameters
                   raw.permit!.to_unsafe_h
                 when Hash
                   raw
                 else
                   {}
                 end
      incoming = incoming.deep_stringify_keys
      base = @study&.persisted? && @study.metadata.is_a?(Hash) ? @study.metadata.deep_stringify_keys : {}
      merged = base.merge(incoming)
      merged.delete('ai_system_prompt')
      permitted[:metadata] = merged
    end
    permitted
  end

  def study_total_duration_by_id(studies)
    ids = studies.map(&:id)
    return {} if ids.empty?

    StudyPlanItem
      .where(study_id: ids)
      .where('duration > 0')
      .group(:study_id)
      .sum(:duration)
  end
end
