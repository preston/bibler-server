# frozen_string_literal: true

# Author: Preston Lee
class BiblesController < ApplicationController
  def index
    @bibles = Bible.all
  end

  def show
    @bible = Bible.find(params[:id])
  end
end
