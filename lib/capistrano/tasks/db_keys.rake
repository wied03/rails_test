require 'chef-vault'

def get_user_private_key(username)
  bag = "#{fetch(:stage)}_db"
  item = "user_#{username}_key"
  info "Fetching private key for username #{username} from databag #{bag}, item #{item}"
  ChefVault::Item.load(bag, item)['file-content']
end

def get_key_filename(username)
  "pgsql_user_#{username}.key"
end

def scoped(value)
  yield value
end

def upload_key(key_contents,username)
  cert_dir = File.expand_path(File.join(fetch(:deploy_to), '..', 'certs'))
  target = File.join(cert_dir, get_key_filename(username))
  # In case the key is already there, we don't want to leave trails around the disk
  shred_file target
  execute :touch, target
  execute :chmod, '0600', target
  upload! StringIO.new(key_contents),target
end

namespace :bsw do
  namespace :migration do

    desc 'Setup DB private keys for both migration and runtime'
    task :'pull-down-credentials' do
      on primary :web do
        migrate_env = "#{fetch(:rails_env)}-ddl"
        info "Pulling down DB user private keys for environment #{migrate_env}"
        ssl_db_user = fetch(:ssl_db_user)
        ssl_db_migration_user = fetch(:ssl_db_migration_user)
        key_runtime = get_user_private_key ssl_db_user
        key_ddl = get_user_private_key ssl_db_migration_user
        info 'Keys fetched, uploading to server'
        upload_key key_runtime, ssl_db_user
        upload_key key_ddl, ssl_db_migration_user

        # Will force migrate to use our different environment in the YAML file
        set :rails_env, migrate_env
      end
    end

    desc 'Removes DB DDL user private key'
    task :'remove-credentials' do
      on primary :web do
        info 'Removing DDL user private key'
        ssl_db_migration_user = fetch(:ssl_db_migration_user)
        scoped File.expand_path(File.join(fetch(:deploy_to), '..', 'certs')) do |cert_dir|
          shred_file File.join(cert_dir, get_key_filename(ssl_db_migration_user))
        end
      end
    end
  end
end

before 'deploy:migrate', 'bsw:migration:pull-down-credentials'
after 'deploy:migrate', 'bsw:migration:remove-credentials'
after 'deploy:failed', 'bsw:migration:remove-credentials'
