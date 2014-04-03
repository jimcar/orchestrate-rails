tests = File.expand_path('..', __FILE__)
$LOAD_PATH.unshift(tests) unless $LOAD_PATH.include?(tests)

  require 'orchestrate-api'
  require 'orchestrate-rails'

  require 'rubygems'
  require 'minitest/autorun'

  require 'vcr'

  require 'tests/record-orchio_delete'
  require 'tests/record-orchio_event'
  require 'tests/record-orchio_get'
  require 'tests/record-orchio_graph'
  require 'tests/record-orchio_list'
  require 'tests/record-orchio_put'
  require 'tests/record-orchio_search'

  require 'tests/ref_table'

  require 'tests/model-create'
  require 'tests/model-save'
  require 'tests/model-update'
  require 'tests/model-get'
  require 'tests/model-find'
  require 'tests/model-all'
  require 'tests/model-list'
  require 'tests/model-search'
  require 'tests/model-attributes'
  require 'tests/model-destroy'
  require 'tests/model-event'
  require 'tests/model-graph'

  module Test

    class TestModel < Orchestrate::Rails::Model
    end

    def self.setup_the_test
      Orchestrate::Application::Connect.config File.join(File.dirname(__FILE__), "lib", "orch_config-demo.json")
      Orchestrate::Rails::Schema.instance.load File.join(File.dirname(__FILE__), "db/schema_rails_test.rb")
    end

    def self.output_message(name, msg = nil)
      msg = "START TEST" if msg.blank?
      puts "\n======= #{msg}: #{name} ======="
    end

    VCR.configure do |c|
      # c.allow_http_connections_when_no_cassette = true
      c.hook_into :webmock
      c.cassette_library_dir = File.join(File.dirname(__FILE__), "fixtures", "vcr_cassettes")
      default_cassette_options = { :record => :all }
    end

    class VCRTest_OrchestrateApplication_Record < MiniTest::Unit::TestCase
      include Test::OrchioDelete
      include Test::OrchioEvent
      include Test::OrchioGet
      include Test::OrchioGraph
      include Test::OrchioList
      include Test::OrchioPut
      include Test::OrchioSearch
    end

    class VCRTest_OrchestrateApplication_RefTable < MiniTest::Unit::TestCase
      include Test::RefTable
    end

    class VCRTest_OrchestrateRails_Model < MiniTest::Unit::TestCase
      include Test::All
      include Test::Attributes
      include Test::Create
      include Test::Destroy
      include Test::Event
      include Test::Find
      include Test::Get
      include Test::Graph
      include Test::List
      include Test::Save
      include Test::Search
      include Test::Update
    end

    # VCRTestOrchestrateApplication.new(:test)
    # VCRTestOrchestrateRails.new(:test)

  end

