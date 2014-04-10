require "orchestrate/api"
require "orchestrate-rails"

require "active_support"
require "minitest/autorun"
require "vcr"

# Configure Orchestrate-Rails ------------------------------------------------

Orchestrate.configure do |config|
  config.api_key = ENV["TEST_API_KEY"]
  config.verbose = true
end

# Orchestrate::Application::Connect.config File.join(File.dirname(__FILE__), "lib", "orch_config-demo.json")
Orchestrate::Rails::Schema.instance.load File.join(File.dirname(__FILE__), "db/schema_rails_test.rb")

# Configure VCR --------------------------------------------------------------

VCR.configure do |c|
  # c.allow_http_connections_when_no_cassette = true
  c.hook_into :webmock
  c.cassette_library_dir = File.join(File.dirname(__FILE__), "fixtures", "vcr_cassettes")
  default_cassette_options = { :record => :all }
end

# Test Helpers ---------------------------------------------------------------

def output_message(name, msg = nil)
  msg = "START TEST" if msg.blank?
  puts "\n======= #{msg}: #{name} ======="
end

# Shared Test Model ---------------------------------------------------------

module Test
  class TestModel < Orchestrate::Rails::Model
  end

  class TestEvent < Orchestrate::Rails::Event
  end
end
