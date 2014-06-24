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

def get_cert_dir
  File.expand_path(File.join(fetch(:deploy_to), '..', 'certs'))
end

def get_all_keys_wildcard
  File.join get_cert_dir, '*.key'
end

def upload_key(runtime_user=false, key_contents, username)
  target = File.join(get_cert_dir, get_key_filename(username))
  execute :touch, target
  execute :chmod, '0600', target
  upload! StringIO.new(key_contents), target
  # Only the running user can view/use the key, so must give it away
  if runtime_user
    execute :sudo,
            '/bin/chown',
            fetch(:web_server_user),
            '-R',
            get_all_keys_wildcard
  end
end

namespace :bsw do
  namespace :ssl_keys do
    task :'clear-keys' do
      on primary :web do
        # In case the key is already there, we don't want to leave trails around the disk
        execute :sudo,
                :shred,
                '-n',
                20,
                '-z',
                '-u',
                get_all_keys_wildcard,
                '||',
                'true'
        end
    end

    desc 'Setup DB private keys for both migration and runtime'
    task :'pull-down-ddl-credentials' do
      on primary :web do
        migrate_env = "#{fetch(:rails_env)}-ddl"
        info "Pulling down DB user private keys for environment #{migrate_env}"
        ssl_db_migration_user = fetch(:ssl_db_migration_user)
        key_ddl = get_user_private_key ssl_db_migration_user
        info 'Keys fetched, uploading to server'
        upload_key key_ddl, ssl_db_migration_user

        # Will force migrate to use our different environment in the YAML file
        set :rails_env, migrate_env
      end
    end

    task :'pull-down-runtime-credentials' do
      on roles(:web) do
        ssl_db_user = fetch(:ssl_db_user)
        key_runtime = get_user_private_key ssl_db_user
        info 'Keys fetched, uploading to server'
        upload_key true, key_runtime, ssl_db_user
      end
    end

    desc 'Removes DB DDL user private key'
    task :'remove-ddl-credentials' do
      on primary :web do
        info 'Removing DDL user private key'
        ssl_db_migration_user = fetch(:ssl_db_migration_user)
        scoped get_cert_dir do |cert_dir|
          shred_file File.join(cert_dir, get_key_filename(ssl_db_migration_user))
        end
      end
    end

    before 'deploy:migrate', 'bsw:ssl_keys:clear-keys'
    # Runtime needs to go first because of the chown that gives the key to the app owner
    before 'deploy:migrate', 'bsw:ssl_keys:pull-down-runtime-credentials'
    before 'deploy:migrate', 'bsw:ssl_keys:pull-down-ddl-credentials'
    after 'deploy:migrate', 'bsw:ssl_keys:remove-ddl-credentials'
    after 'deploy:failed', 'bsw:ssl_keys:remove-ddl-credentials'
  end
end

