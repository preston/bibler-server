class BooksController < ApplicationController

  before_action :set_book, only: [:show]

  def index
    render json: Book.includes(:testament).order('testament_id ASC', 'ordinal ASC'), include: :testament
  end

  def show
    @book = Book.find(params[:id])
    if @book
      render json: @book, include: :testament
    else
      render status: :not_found
    end
  end


end
