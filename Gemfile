# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.2.2'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '>= 7.0.4.3'
# Use Puma as the app server
gem 'puma'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder' # , '>= 2.7.0'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
gem 'rack-cors'

gem 'friendly_id'
gem 'pg'
gem 'pg_search'

group :test do
  gem 'rails-controller-testing'
end

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'guard'
  gem 'guard-minitest'
  gem 'railroady'
  gem 'rubocop' # For editor reformatting support
end

group :development do
  gem 'binding_of_caller'
  gem 'listen' # , '>= 3.5.1'
  gem 'web-console'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen' # , '~> 2.0.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
