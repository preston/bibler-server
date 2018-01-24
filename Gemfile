source 'https://rubygems.org'
ruby '2.4.2'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '5.1.4'
# gem 'sass-rails'  #, '~> 5.0'
# gem 'uglifier'  #, '>= 1.3.0'

# FIXME Should be able to eventually remove this:
#gem 'sprockets', '>= 2.12.4' # http://stackoverflow.com/questions/34391858/error-while-trying-angularjs-with-railsundefined-method-register-engine-for-n
gem 'sprockets', '>= 3.7.1' # http://stackoverflow.com/questions/34391858/error-while-trying-angularjs-with-railsundefined-method-register-engine-for-n

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '>= 2.7.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '>= 0.4.2', group: :doc

gem 'friendly_id'

# Required at deploy time.
gem 'therubyracer'

# Better web server
gem 'puma'

gem 'pg', '~>0.21.0'
gem 'pg_search'

# Use Capistrano for deployment
group :development do
	gem 'sitemap_generator'
end

group :development, :test do
	# gem 'web-console', '~> 2.0'     # Access an IRB console on exception pages or by using <%= console %> in views
    gem 'spring' # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
    gem 'guard'
	gem 'guard-minitest'
    gem 'railroady'
    gem 'rubocop' # For editor reformatting support
	gem 'byebug' # Call 'byebug' anywhere in the code to stop execution and get a debugger console
	gem 'web-console'
	gem 'binding_of_caller'
end
