# config valid only for Capistrano 3.1
lock '3.2.1'

set :application, 'rails_test'
set :repo_url, 'git@github.com:wied03/rails_test.git'

# Default deploy_to directory is /var/www/my_app
set :deploy_to, '/var/www/my_app'

# Default value for :linked_files is []
# set :linked_files, %w{config/database.yml}

# Default value for linked_dirs is []
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

# TODO: Fix the rvm gem?
ruby_version = ::File.read('.ruby-version').strip
set :rvm1_ruby_version, ruby_version
# TODO: Put these lines in a separate, reusable GEM
before 'bundler:install', 'rvm1:install:ruby'
set :migration_role, 'web'
set :conditionally_migrate, true
set :ssl_db_user, lambda { raise "You need to configure ssl_db_user in your environment file like this 'set :ssl_db_user, 'theuser'"}
set :ssl_db_migration_user, lambda {
  prefix = /(.*)_user/.match(fetch(:ssl_db_user))[1]
  "#{prefix}_ddl"
}
set :rvm_environment_variables, {}
set :linked_files, %w{.ruby-env}
set :web_server_user, 'www-data'
# TODO: End lines

namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
      # execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  after :publishing, :restart

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

end
