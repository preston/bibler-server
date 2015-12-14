Rails.application.routes.draw do

  get 'welcome/index'
  get 'welcome/reader', as: :reader
  get 'welcome/comparator', as: :comparator
  get 'welcome/search', as: :search
  get '/api' => 'welcome#api', as: :api

  resources :testaments, only: [:index, :show]
  resources :books, only: [:index, :show]
  resources :verses, only: [:index, :show]
  resources :bibles, only: [:index, :show]
  get ':bible/:book/:chapter/:ordinal' => "verses#show", as: :verse_lookup
  get ':bible/:book' => "verses#chapters", as: :bible_book_chapters
  get ':bible/:book/:chapter' => "verses#verses", as: :bible_book_chapter_verses
  post ':bible/search' => "verses#search", as: :bible_search

  root 'welcome#index'

end
