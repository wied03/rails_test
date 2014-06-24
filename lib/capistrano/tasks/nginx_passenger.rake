namespace :bsw do
  namespace :passenger do
    desc 'Installs Passenger native support into our Ruby'
    task :'install-native-support' do
      on roles(:web) do
        within release_path do
          execute 'bundle',
                  'exec',
                  'passenger-config',
                  'build-native-support'
        end
      end
    end
  end
end

after 'bundler:install', 'bsw:passenger:install-native-support'