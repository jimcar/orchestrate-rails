require_relative "../../test_helper"

class RecordOrchioGetTest < MiniTest::Unit::TestCase

  include Test

  def setup
    @test_root_name = 'application/orchio_get'
  end

  # instance methods: orchio_get, orchio_get_by_ref
  #
  def test_orchio_get

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

      test_result = test_instance.orchio_get
      assert test_result.success?
      assert test_result.results.first.key_value_pairs['Name'] == 'test_1b'
      assert test_result.results.first.key_value_pairs['DESC'] == 'desc_1b'

      ref_result = test_instance.orchio_get_by_ref(ref_value_1a)
      assert ref_result.success?
      assert ref_result.results.first.metadata.key == 'instance_1'
      assert ref_result.results.first.key_value_pairs['Name'] == 'test_1a'
      assert ref_result.results.first.key_value_pairs['DESC'] == 'desc_1a'
    end

    # cleanup
    VCR.use_cassette("#{@test_root_name}/cleanup") do
      status = TestModel.destroy!('instance_1')
      assert status == true
    end
  end
end
