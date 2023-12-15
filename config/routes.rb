# frozen_string_literal: true

Rails.application.routes.draw do
  resources :testaments, only: %i[index show]
  resources :books, only: %i[index show]
  # resources :verses, only: [:index, :show]
  resources :bibles, only: %i[index show]
  get ':bible/:book/:chapter/:ordinal' => 'verses#show', as: :verse_lookup
  get ':bible/:book' => 'verses#chapters', as: :bible_book_chapters
  get ':bible/:book/:chapter' => 'verses#verses', as: :bible_book_chapter_verses
  post ':bible/search' => 'verses#search', as: :bible_search
end
