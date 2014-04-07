require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new do |t|
  t.libs << "lib/orchestrate-rails"
  t.test_files = FileList["test/tests/**/*_test.rb"]
  t.verbose = true
end

task default: :test