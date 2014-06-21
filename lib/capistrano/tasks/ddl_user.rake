require 'chef-vault'

def get_user_private_key(username)
  bag = "#{fetch(:stage)}_db"
  item = "user_#{username}_key"
  ChefVault::Item.load(bag, item)['file-content']
end

namespace :bsw do
  namespace :migration do

    desc 'Setup DB private keys for both migration and runtime'
    task :'pull-down-credentials' do
      on primary :web do
        migrate_env = "#{fetch(:rails_env)}-ddl"
        info "Pulling down DDL user private key for environment #{migrate_env}"
        info "Found pri key #{get_user_private_key('rails_ddl')}"
        # Will force migrate to use our different environment in the YAML file
        set :rails_env, migrate_env
        # TODO: Use Chef vault and store these in a file in /var/www/certs
      end
    end

    desc 'Removes DB DDL user private key'
    task :'remove-credentials' do
      on primary :web do
        info 'Removing DDL user private key'
        # TODO: Shred and remove the file form /var/www/certs
      end
    end
  end
end

before 'deploy:migrate', 'bsw:migration:pull-down-credentials'
after 'deploy:migrate', 'bsw:migration:remove-credentials'
after 'deploy:failed', 'bsw:migration:remove-credentials'
