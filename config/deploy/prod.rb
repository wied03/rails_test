require 'capistrano/chef'

set :user, 'app_owner'
bsw_chef_role :web
populate_chef_props

set :rails_env, 'ci'
