workers Integer(ENV['WEB_CONCURRENCY'] || 2)
threads_count = Integer(ENV['MAX_THREADS'] || 5)
threads threads_count, threads_count

preload_app!

rackup      DefaultRackup
port        ENV['PORT']     # || 3000
environment ENV['RACK_ENV'] || 'development'

# If you'd like to test with TLS/SSL instead of raw HTTP, you may use:
# bind "ssl://127.0.0.1:#{ENV['PORT']}?key=./doc/ssl/development.key&cert=./doc/ssl/development.crt"

on_worker_boot do
  # Worker specific setup for Rails 4.1+
  # See: https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server#on-worker-boot
  ActiveRecord::Base.establish_connection
end
