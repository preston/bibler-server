# frozen_string_literal: true

# Author: Preston Lee
class StudyRolesController < ApplicationController
  include StudyContext

  def show
    @study_mode = requested_study_mode
  end

  def update
    @study_mode = requested_study_mode
    render :show, status: :ok
  end
end
