require_relative "../../test_helper"

class ModelGetTest < MiniTest::Unit::TestCase

  include Test

  def setup
    @test_root_name = 'rails/get'
  end

  # instance methods: get, get_by_ref
  #
  def test_get

    output_message(@test_root_name)

    test_instance = ref_value_1a = nil

    # setup
    VCR.use_cassette("#{@test_root_name}/setup") do
      test_instance = TestModel.create!(id: 'instance_1', name: 'test_1a', desc: 'desc_1a')
      assert test_instance != false
      ref_value_1a = test_instance.orchestrate_ref_value
      status = test_instance.update_attributes!(name: 'test_1b', desc: 'desc_1b')
      assert status != false
      assert ref_value_1a != test_instance.orchestrate_ref_value
    end

    # test
    VCR.use_cassette("#{@test_root_name}/synopsis") do

      test_instance = test_instance.get
      assert test_instance != false
      assert test_instance.name == 'test_1b'
      assert test_instance.desc == 'desc_1b'

      ref_instance = test_instance.get_by_ref(ref_value_1a)
      assert ref_instance != nil
      assert ref_instance.id == 'instance_1'
      assert ref_instance.name == 'test_1a'
      assert ref_instance.desc == 'desc_1a'
    end

    # cleanup
    VCR.use_cassette("#{@test_root_name}/cleanup") do
      status = TestModel.destroy!('instance_1')
      assert status == true
    end
  end
end
