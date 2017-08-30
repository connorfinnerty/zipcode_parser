# This Rakefile has all the right settings to run the tests inside each dir
gem 'rspec'
require 'rspec/core/rake_task'

task :default => :spec

desc "use rake to run tests"
RSpec::Core::RakeTask.new do |task|
  dir = Rake.application.original_dir
  task.pattern = "#{dir}/*_spec.rb"
  task.rspec_opts = [ "-I#{dir}", "-I#{dir}/solution", '-f documentation', '-r ./rspec_config']
  task.verbose = false
end
