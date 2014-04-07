require_relative "../../test_helper"

class RecordOrchioEventTest < MiniTest::Unit::TestCase

  include Test

  def setup
    @test_root_name = 'application/orchio_event'
  end

  def get_timestamp
    (Time.now.to_f * 1000).to_i
  end

  # instance methods: orchio_put_event, orchio_get_events
  #
  def test_event

    output_message(@test_root_name)

    test_instance = nil

    # setup
    VCR.use_cassette("#{@test_root_name}/setup") do
      status = TestModel.destroy!('instance_1')
      assert status == true

      test_instance = TestModel.create!(id: 'instance_1', name: 'test_1a', desc: 'desc_1a')
      assert test_instance != false
    end

    # test
    VCR.use_cassette("#{@test_root_name}/synopsis") do

      event_result = test_instance.orchio_get_events('test_event')
      assert event_result.results.length == 0

      jdoc = { name: 'name_1', contents: 'stuff_1' }.to_json
      status = test_instance.orchio_put_event('test_event', nil, jdoc)
      assert status == true

      jdoc = { name: 'name_2', contents: 'stuff_2' }.to_json
      status = test_instance.orchio_put_event('test_event', nil, jdoc)
      assert status == true

      event_result = test_instance.orchio_get_events('test_event')
      assert event_result.results.length == 2

      t1 = 1395441226763  # get_timestamp() from approx 3:30pm PDT on 03-21-2014
      jdoc = { name: 'name_3', contents: 'stuff_3' }.to_json
      status = test_instance.orchio_put_event('test_event', t1, jdoc)
      assert status == true

      t2 = t1 + 100
      jdoc = { name: 'name_4', contents: 'stuff_4' }.to_json
      status = test_instance.orchio_put_event('test_event', t2, jdoc)
      assert status == true

      event_result = test_instance.orchio_get_events('test_event')
      assert event_result.results.length == 4

      t1_t2 = { :start => t1, :end => t2 + 1 }
      event_result = test_instance.orchio_get_events('test_event', t1_t2)
      assert event_result.results.length == 2
    end

    # cleanup
    VCR.use_cassette("#{@test_root_name}/cleanup") do
      status = TestModel.destroy!('instance_1')
      assert status == true
    end
  end
end
