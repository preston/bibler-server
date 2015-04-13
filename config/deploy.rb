# config valid only for current version of Capistrano
# lock '3.3.5'

set :application, 'bibler'
set :repo_url, 'git@github.com:preston/bibler.git'

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, '/var/www/my_app_name'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true


# Default value for :linked_files is []
# set :linked_files, fetch(:linked_files, []).push('config/database.yml')
set :linked_files, %w{config/database.yml config/secrets.yml}

# Default value for linked_dirs is []
# set :linked_dirs, fetch(:linked_dirs, []).push('bin', 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')
set :linked_dirs, fetch(:linked_dirs, []).push('bin', 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
set :keep_releases, 3

namespace :deploy do

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end


  after :finishing, 'deploy:cleanup'

end

# Hack from: https://gist.github.com/corny/7459729
# Overwrite the 'deploy:updating' task.
# Rake::Task["deploy:updating"].clear_actions
# namespace :deploy do

#   desc 'Copy repo to releases, along with submodules'
#   task updating: :'git:update' do
#     on roles(:all) do
#       with fetch(:git_environmental_variables) do
#         within repo_path do
#           # We'll be using 'git clone' instead of 'git archive' (what Capistrano uses), since the latter doesn't fetch submodules.
#           # Use --recursive to fetch submodules as well.
#           execute :git, :clone, '-b', fetch(:branch), '--recursive', '.', release_path
#           # Delete .git* files. We don't need them, and they can be a security threat.
#           execute "find #{release_path} \\( -name '.git' -o -name '.gitignore' -o -name '.gitmodules' \\) -exec rm -rf {} \\; > /dev/null 2>&1", raise_on_non_zero_exit: false
#         end
#       end
#     end
#   end

# end

