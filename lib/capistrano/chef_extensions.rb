module Capistrano
  class Configuration
    # We want our chef properties to be usable from Capistrano
    def populate_chef_props
      servers.each do |server|
        puts "Retrieving chef props for #{server.hostname}"
        node = Module.const_get(:Chef)::Node.load(server.hostname)
        the_env = Module.const_get(:Chef)::Environment.load(node.environment)
        puts "Merging in props from environment #{the_env.name}"
        node.env_default = the_env.default_attributes
        server.properties.chef_props = node.merged_attributes
      end
    end
  end
  module DSL
    module Env
      def populate_chef_props
        env.populate_chef_props
      end

      # Reuse this pattern / less code
      def bsw_chef_role(role)
        # use role, not 'roles' because roles retrieves the expanded run list, which is derived after the first Chef run
        chef_role role, "role:#{role}", :attribute => :fqdn
      end
    end
  end
end
