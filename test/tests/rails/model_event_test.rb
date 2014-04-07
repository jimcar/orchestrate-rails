require_relative "../../test_helper"

class ModelEventTest < MiniTest::Unit::TestCase

  include Test

  def setup
    @test_root_name = 'rails/event'
  end

  def get_timestamp
    (Time.now.to_f * 1000).to_i
  end

  # instance methods:  create_event, save_event, events
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
      event_instances = test_instance.events('test_event')
      assert event_instances.length == 0

      event_instance =
        test_instance.create_event('test_event', nil, { name: 'name_1', contents: 'stuff_1' })
      assert event_instance != false
      assert event_instance.name == 'name_1'
      assert event_instance.contents == 'stuff_1'

      event_instance =
        test_instance.save_event('test_event', nil, TestEvent.new(name: 'name_2', contents: 'stuff_2'))
      assert event_instance != false
      assert event_instance.name == 'name_2'
      assert event_instance.contents == 'stuff_2'

      event_instances = test_instance.events('test_event')
      assert event_instances.length == 2

      t1 = 1395441226763  # get_timestamp() from approx 3:30pm PDT on 03-21-2014
      t2 = t1 + 100
      event_instance =
        test_instance.create_event('test_event', t1, { name: 'name_3', contents: 'stuff_3' })
      assert event_instance != false
      assert event_instance.name == 'name_3'
      assert event_instance.contents == 'stuff_3'

      event_instance =
        test_instance.create_event('test_event', t2, { name: 'name_4', contents: 'stuff_4' })
      assert event_instance != false
      assert event_instance.name == 'name_4'
      assert event_instance.contents == 'stuff_4'

      event_instances = test_instance.events('test_event')
      assert event_instances.length == 4

      t1_t2 = { :start => t1, :end => t2 + 1 }
      event_instances = test_instance.events('test_event', t1_t2)
      assert event_instances.length == 2
    end

    # cleanup
    VCR.use_cassette("#{@test_root_name}/cleanup") do
      status = TestModel.destroy!('instance_1')
      assert status == true
    end
  end

end
