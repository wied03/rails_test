namespace :bsw do
  namespace :migration do

    desc 'Setup DB DDL user private key for deployment'
    task :'pull-down-credentials' do
      on primary :web do
        info 'Pulling down credentials'
      end
    end

    desc 'Removes DB DDL user private key'
    task :'remove-credentials' do
      on primary :web do
        info 'Removing credentials'
      end
    end
  end
end

before 'deploy:migrate', 'bsw:migration:pull-down-credentials'
after 'deploy:migrate', 'bsw:migration:remove-credentials'
after 'deploy:failed', 'bsw:migration:remove-credentials'
