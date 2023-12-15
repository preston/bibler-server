# frozen_string_literal: true

# Author: Preston Lee
class TestamentsController < ApplicationController
  def index
    @testaments = Testament.all
  end

  def show
    @testament = Testament.find(params[:id])
  end
end
