namespace :bsw do
  namespace :'split-users' do
    desc 'Ensures tmp and log access for user running the app'
    task :'adjust-permissions' do
      on roles(:web) do
        within release_path do
          permissions = 'u+rw,g+w'
          execute :mkdir,
                  'tmp',
                  '|| true'
          execute :chmod,
                  permissions,
                  'log tmp'
        end
      end
    end
  end
end

before 'deploy:publishing', 'bsw:split-users:adjust-permissions'