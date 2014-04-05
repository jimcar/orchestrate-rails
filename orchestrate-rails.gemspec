lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'orchestrate/rails/version'

Gem::Specification.new do |spec|
  spec.name          = "orchestrate-rails"
  spec.version       = Orchestrate::Rails::VERSION
  spec.authors       = ["James Carrasquer"]
  spec.email         = ["jimcar@aracnet.com"]
  spec.summary       = "Summary for orchestrate-rails"
  spec.description   = "Maps rails models to Orchestrate.io DBaaS"
  spec.homepage      = "https://github.com/jimcar/orchestrate-rails"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "vcr"
  spec.add_development_dependency "webmock"

  spec.add_runtime_dependency "orchestrate-api"
end
