require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new do |t|
  t.libs << "lib/orchestreate-rails"
  t.test_files = ["test/test-rails.rb"]
  t.verbose = true
end

task default: :test
