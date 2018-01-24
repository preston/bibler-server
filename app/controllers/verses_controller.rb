class VersesController < ApplicationController

  before_action :set_context, except: [:search]

  SEARCH_LIMIT = 100

  def show
    @verse = Verse.where(bible: @bible, book: @book, chapter: params[:chapter], ordinal: params[:ordinal]).first
    respond_to do |format|
      format.json { render json: @verse, include: [:book, :bible] }
      format.xml { render xml: @verse, include: [:book, :bible] }
    end
  end

  def verses
    @verses = Verse.where(bible: @bible, book: @book, chapter: params[:chapter]).order('ordinal ASC')
    render json: @verses
  end

  def chapters
    @chapters = Verse.where(bible: @bible, book: @book).uniq.pluck(:chapter).sort
    # @verses = Verse.where(bible: bible, book: book, chapter: params[:chapter])
    render json: @chapters
  end

  def search
    t = params[:text]
    bible = Bible.find(params[:bible])
    @verses = Verse.limit(SEARCH_LIMIT).where(bible: bible).search_by_text(t).includes(:book)
    render json: @verses, include: :book
  end

  private

  def set_context
    @bible = Bible.find(params[:bible])
    @book = Book.find(params[:book])
  end

end
