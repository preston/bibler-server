# frozen_string_literal: true

# Author: Preston Lee
class BooksController < ApplicationController
  def index
    @books = Book.includes(:testament, :bible)
    
    # Filter by bible if bible_id is provided (from nested route or query param)
    bible_id = params[:bible_id] || params[:id]
    if bible_id.present?
      # Handle both ID and slug lookups for bible
      bible = Bible.find_by(id: bible_id) || Bible.find_by(slug: bible_id)
      if bible
        @books = @books.where(bible_id: bible.id)
      end
    end
    
    @books = @books.order('testament_id ASC', 'ordinal ASC')
  end

  def show
    # If bible_id is provided (from nested route), scope the lookup to that bible
    if params[:bible_id].present?
      bible = Bible.find_by(id: params[:bible_id]) || Bible.find_by(slug: params[:bible_id])
      if bible
        @book = bible.books.find(params[:id])
      else
        head :not_found
        return
      end
    else
      @book = Book.find(params[:id])
    end
  end
end
