require "bundler/gem_tasks"
require "rake/testtask"
require "rdoc/task"

task default: :test

Rake::TestTask.new do |t|
  t.libs << "lib/orchestrate-rails"
  t.test_files = FileList["test/tests/**/*_test.rb"]
  t.verbose = true
end

Rake::RDocTask.new(rdoc: "doc", clobber_rdoc: "doc:clean", rerdoc: "doc:force") do |rdoc|
  rdoc.main = "README.md"
  rdoc.title = "Orchestrate Rails Documentation"
  rdoc.options << "--all"
  rdoc.options << "--line-numbers"
  rdoc.rdoc_files.include("README.md", "lib/**/*.rb")
  rdoc.rdoc_dir = "doc"
end
