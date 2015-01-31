class TestamentsController < ApplicationController

  def index
    render json: Testament.all
  end

  def show
    @testament = Testament.find(params[:id])
  end

end
