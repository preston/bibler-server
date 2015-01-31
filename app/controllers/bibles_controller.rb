class BiblesController < ApplicationController

  def index
    render json: Bible.all
  end

  def show
    @bible = Bible.find(params[:id])
  end

end
