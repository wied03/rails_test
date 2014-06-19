# Use our shared knife code
current_dir = File.dirname(__FILE__)
instance_eval(File.read(File.join(File.dirname(__FILE__), 'knife-shared.rb')))

log_level                :info
log_location             STDOUT
node_name                'admin'
chef_server_url          'https://chef-sandbox.weez.wied.us:8443'
syntax_check_cache_path  'syntax_check_cache'
cookbook_path [ './cookbooks' ]
# Knife/chef vault settings
knife[:vault_mode] = 'client'
knife[:vault_admins] = [ 'admin' ]
