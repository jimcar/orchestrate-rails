require_relative "../../test_helper"

class RecordOrchioDeleteTest < MiniTest::Unit::TestCase

  include Test

  def setup
    @test_root_name = 'application/orchio_delete'
  end

  # class methods: orchio_delete, orchio_delete_key
  #
  # instance methods: orchio_delete, orchio_purge
  #
  def test_orchio_delete

    output_message(@test_root_name)

    ref_value_1a = ref_value_1b = ref_value_1c = nil
    ref_value_4a = ref_value_4b = ref_value_4c = nil

    # setup
    VCR.use_cassette("#{@test_root_name}/setup") do

      test_instance = TestModel.create!(id: 'instance_1', name: 'test_1a', desc: 'desc_1a')
      assert test_instance != false
      ref_value_1a = test_instance.orchestrate_ref_value

      status = test_instance.update_attributes!(name: 'test_1b', desc: 'desc_1b')
      assert status != false
      ref_value_1b = test_instance.orchestrate_ref_value
      assert ref_value_1b != ref_value_1a

      status = test_instance.update_attributes!(name: 'test_1c', desc: 'desc_1c')
      assert status != false
      ref_value_1c = test_instance.orchestrate_ref_value
      assert ref_value_1c != ref_value_1a
      assert ref_value_1c != ref_value_1b

      test_instance = TestModel.create!(id: 'instance_2', name: 'test_2a', desc: 'desc_2a')
      assert test_instance != false

      test_instance = TestModel.create!(id: 'instance_3', name: 'test_3a', desc: 'desc_3a')
      assert test_instance != false

      test_instance = TestModel.create!(id: 'instance_4', name: 'test_4a', desc: 'desc_4a')
      assert test_instance != false
      ref_value_4a = test_instance.orchestrate_ref_value

      status = test_instance.update_attributes!(name: 'test_4b', desc: 'desc_4b')
      assert status != false
      ref_value_4b = test_instance.orchestrate_ref_value
      assert ref_value_4b != ref_value_4a

      status = test_instance.update_attributes!(name: 'test_4c', desc: 'desc_4c')
      assert status != false
      ref_value_4c = test_instance.orchestrate_ref_value
      assert ref_value_4c != ref_value_4a
      assert ref_value_4c != ref_value_4b

      assert TestModel.all.length == 4
    end

    # test
    output_message(@test_root_name, "TEST START")

    VCR.use_cassette("#{@test_root_name}/synopsis") do

      status = TestModel.orchio_delete_key('test_models', 'instance_4')
      assert status == true
      assert TestModel.all.length == 3

      test_instance = TestModel.new(id: 'instance_4')
      result = test_instance.orchio_get
      assert result.success? == false

      ref_instance = test_instance.get_by_ref(ref_value_4a)
      assert ref_instance != false
      assert ref_instance.id == 'instance_4'
      assert ref_instance.name == 'test_4a'

      status = test_instance.orchio_purge
      assert status == true

      ref_instance = TestModel.new(id: 'instance_4').get_by_ref(ref_value_4a)
      assert ref_instance == false

      test_instance = TestModel.new(id: 'instance_1')
      status = test_instance.orchio_delete
      assert status == true
      assert TestModel.all.length == 2

      result = test_instance.orchio_get
      assert result.success? == false

      ref_instance = test_instance.get_by_ref(ref_value_1a)
      assert ref_instance != nil
      assert ref_instance.id == 'instance_1'
      assert ref_instance.name == 'test_1a'

      ref_instance = test_instance.get_by_ref(ref_value_1b)
      assert ref_instance != nil
      assert ref_instance.id == 'instance_1'
      assert ref_instance.desc == 'desc_1b'

      ref_instance = test_instance.get_by_ref(ref_value_1c)
      assert ref_instance != false
      assert ref_instance.id == 'instance_1'
      assert ref_instance.name == 'test_1c'

      status = test_instance.orchio_purge
      assert status == true

      ref_instance = test_instance.get_by_ref(ref_value_1a)
      assert ref_instance == false

      ref_instance = test_instance.get_by_ref(ref_value_1b)
      assert ref_instance == false

      ref_instance = test_instance.get_by_ref(ref_value_1c)
      assert ref_instance == false

      status = TestModel.orchio_delete 'test_models'
      assert status == true
      sleep 1
      assert TestModel.all.length == 0
    end

    # cleanup
    output_message(@test_root_name, "Test cleanup")

    VCR.use_cassette("#{@test_root_name}/cleanup") do
      status = TestModel.destroy!('instance_1')
      assert status == true
      status = TestModel.destroy!('instance_2')
      assert status == true
      status = TestModel.destroy!('instance_3')
      assert status == true
      status = TestModel.destroy!('instance_4')
      assert status == true
    end
  end
end
