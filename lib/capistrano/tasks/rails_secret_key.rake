def get_rails_secret_key
  bag = "#{fetch(:stage)}_rails"
  ChefVault::Item.load(bag, 'secret_key_base')['file-content']
end


namespace :bsw do
  namespace :rails do
    task :'secret-key-base' do
      on roles(:web), in: :sequence do
        # TODO: Check if key is there already, if not, shred and rebuild file
        secret = get_rails_secret_key
        vars = fetch(:rvm_environment_variables)
        vars['SECRET_KEY_BASE'] = secret
        ruby_env = File.join shared_path,'.ruby-env'
        execute :touch, ruby_env
        execute :chmod, '0600', ruby_env
        contents = (vars.map {|k,v| "#{k}=\"#{v}\""}).join("\n")
        upload! StringIO.new(contents),ruby_env
      end
    end
  end
end

# Need to run before check because a symlink to this file will happen there
before 'deploy:check', 'bsw:rails:secret-key-base'