# frozen_string_literal: true

# Author: Preston Lee
class BiblesController < ApplicationController
  def index
    @bibles = Bible.all
  end

  def show
    @bible = Bible.find_by!(uuid: params[:uuid])
  end
end
