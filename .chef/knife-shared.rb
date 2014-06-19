# current_dir needs to be in current scope to detect file path properly
chef_config = lambda { |*f| File.expand_path(File.join(current_dir,f)) }
chef_encrypted = lambda { |*f| File.expand_path(File.join(ENV['chef_encrypted_dir'],f)) }

# Berkshelf needs absolute path here
client_key              chef_encrypted['admin.pem']
validation_client_name   'chef-validator'
# Knife bootstrap needs an absolute path here
validation_key          chef_encrypted['chef-validator.pem']
# Only keep 1 copy of our certs since we already put them in the cookbook for nodes
trusted_certs_dir = lambda { |*f| chef_config['trusted_certs',f] }
FileUtils.mkdir_p trusted_certs_dir.call
source_certs_dir = chef_config['..','cookbooks','bsw_chefclient','files','default','*.crt']
Dir.glob(source_certs_dir) do |crt|
  destination = trusted_certs_dir[File.basename(crt)]
  if ! File.exists? destination
    puts "SSL cert seed: Copying #{crt} to #{destination}"
    FileUtils.cp crt, destination
  end
end
# Berkshelf/OpenSSL needs to be told about SSL certs not signed by well known internet CAs
pem_file = chef_config['openssl_with_trusted_cert.pem']
if ! File.exists? pem_file
  puts 'Creating SSL trust file for Berkshelf...'
  FileUtils.cp '/etc/openssl/cert.pem', pem_file
  File.open pem_file, 'a' do |concat_file|
    Dir.glob(trusted_certs_dir['*']) do |crt|
      puts "Appending #{crt} to openssl trust chain"
      File.open crt, 'r' do |in_file|
        lines = in_file.each_line do |line|
          concat_file << line
        end
      end
    end
  end
  puts 'Done'
end
ENV['SSL_CERT_FILE'] = pem_file
# End of Berkshelf stuff
# Berkshelf also doesn't like Mac style .DS_Store files
system("find #{chef_config['..']} -name '*.DS_Store' -type f -delete 1> /dev/null 2>&1")
ssl_verify_mode :verify_peer