require 'capistrano/chef'

set :user, 'brady'
bsw_chef_role :web
populate_chef_props
