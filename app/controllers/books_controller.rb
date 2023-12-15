# frozen_string_literal: true

# Author: Preston Lee
class BooksController < ApplicationController
  def index
    @books = Book.includes(:testament).order('testament_id ASC', 'ordinal ASC')
  end

  def show
    @book = Book.find(params[:id])
    # if @book
    # 	render json: @book, include: :testament
    # else
    # 	render status: :not_found
    # end
  end
end
