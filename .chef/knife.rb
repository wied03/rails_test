# Use our shared knife code
# current_dir needs to be in this file
current_dir = File.dirname(__FILE__)

require 'bsw/knife/shared'
Bsw::KnifeShared::load(current_dir, self)

log_level                :info
log_location             STDOUT
node_name                'admin'
chef_server_url          'https://chef-sandbox.weez.wied.us:8443'
syntax_check_cache_path  'syntax_check_cache'
cookbook_path [ './cookbooks' ]
# Knife/chef vault settings
knife[:vault_mode] = 'client'
knife[:vault_admins] = [ 'admin' ]
knife[:bootstrap_version] = '11.16.0'
