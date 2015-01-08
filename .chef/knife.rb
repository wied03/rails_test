log_level                :info
log_location             STDOUT
admin_user = ENV['USER']
node_name                admin_user
prod_chef = ENV['chef_encrypted_dir'].include? 'prod'
chef_server = prod_chef ? 'https://leopard.prod.bswtechconsulting.com/organizations/bsw' : 'https://chef-sandbox.weez.wied.us:8443'
syntax_check_cache_path  'syntax_check_cache'
cookbook_path [ './cookbooks' ]
# Knife/chef vault settings
knife[:vault_mode] = 'client'
knife[:vault_admins] = [ admin_user ]
knife[:bootstrap_version] = '11.16.0'
validation_client_name 'bsw-validator'
require 'bsw/knife/shared'
# Use our shared knife code
# current_dir needs to be in this file
current_dir = File.dirname(__FILE__)
Bsw::KnifeShared::load(current_dir, self, chef_server)