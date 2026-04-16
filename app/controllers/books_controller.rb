# frozen_string_literal: true

# Author: Preston Lee
class BooksController < ApplicationController
  def index
    @books = Book.includes(:testament, :bible)
    
    bible_uuid = params[:bible_uuid] || params[:bible_id]
    if bible_uuid.present?
      bible = Bible.find_by(uuid: bible_uuid)
      if bible
        @books = @books.where(bible_id: bible.id)
      end
    end
    
    @books = @books.order('testament_id ASC', 'ordinal ASC')
  end

  def show
    if params[:bible_uuid].present?
      bible = Bible.find_by(uuid: params[:bible_uuid])
      if bible
        @book = bible.books.find_by!(uuid: params[:uuid])
      else
        head :not_found
        return
      end
    else
      @book = Book.find_by!(uuid: params[:uuid])
    end
  end
end
