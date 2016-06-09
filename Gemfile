source 'https://rubygems.org'
ruby '2.3.1'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.6'
# gem 'sass-rails'  #, '~> 5.0'
# gem 'uglifier'  #, '>= 1.3.0'

# FIXME Should be able to eventually remove this:
gem 'sprockets', '~> 2.12.4' # http://stackoverflow.com/questions/34391858/error-while-trying-angularjs-with-railsundefined-method-register-engine-for-n

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.4.1'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.1', group: :doc

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
