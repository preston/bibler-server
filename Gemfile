source 'https://rubygems.org'
ruby '2.2.3'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.5'
gem 'sass-rails'  #, '~> 5.0'
gem 'uglifier'  #, '>= 1.3.0'

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

# AngularJS
# http://www.intridea.com/blog/2014/9/25/how-to-set-up-angular-with-rails
gem 'angular-rails-templates'
gem 'bower-rails'

gem 'bootstrap-sass'

# Better templating.
gem 'slim-rails'

gem 'friendly_id'

# Required at deploy time.
gem 'therubyracer'

# Better web server
gem 'puma'

# Use Capistrano for deployment
group :development do
	gem 'capistrano-rvm'
	gem 'capistrano-rails-console'
	gem 'capistrano-bundler'
	gem 'capistrano-rails'
	gem 'capistrano-passenger' # Automatically restarts on deploy
	gem 'sitemap_generator'
	gem 'web-console' #, '~> 2.0'
end

group :development, :test do
	# Call 'byebug' anywhere in the code to stop execution and get a debugger console
	gem 'byebug'

	# Access an IRB console on exception pages or by using <%= console %> in views
	gem 'spring'
	gem 'guard'
	gem 'guard-minitest'
	gem 'railroady'
end

# group :production do
	gem 'pg'
	gem 'pg_search'
# end
