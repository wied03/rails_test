require 'ci/reporter/rake/rspec'
require 'ci/reporter/rake/cucumber'

# These need to go before our main Rakefile include
task :cucumber => 'ci:setup:cucumber'
task :spec => 'ci:setup:rspec'
load 'Rakefile'
