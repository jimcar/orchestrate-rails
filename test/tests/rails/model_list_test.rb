require_relative "../../test_helper"

class ModelListTest < MiniTest::Unit::TestCase

  include Test

  def setup
    @test_root_name = 'rails/list'
  end

  # class methods: list
  #
  def test_list

    output_message(@test_root_name)

    # setup
    VCR.use_cassette("#{@test_root_name}/setup") do
      status = TestModel.create!(id: 'instance_2', name: 'test_2a', desc: 'desc_2a')
      assert status != false
      status = TestModel.create!(id: 'instance_1', name: 'test_1a', desc: 'desc_1a')
      assert status != false
      status = TestModel.create!(id: 'instance_3', name: 'test_1a', desc: 'desc_2a')
      assert status != false
    end

    # test
    VCR.use_cassette("#{@test_root_name}/synopsis") do

      test_instances = TestModel.list.results
      assert test_instances.length == 3

      test_instances = TestModel.list(:all).results
      assert test_instances.length == 3

      test_instances = TestModel.list(2).results
      assert test_instances.length == 2

      # test_instances = TestModel.list(0).results
      # assert test_instances.length == 0

      test_instances = TestModel.list(nil, 'instance_3').results
      assert test_instances.length == 1

      test_instances = TestModel.list(nil, 'instance_2').results
      assert test_instances.length == 2

      test_instances = TestModel.list(1, 'instance_2').results
      assert test_instances.length == 1

      test_instances = TestModel.list(nil, nil, 'instance_3').results
      assert test_instances.length == 0

      test_instances = TestModel.list(nil, nil, 'instance_1').results
      assert test_instances.length == 2
    end

    # cleanup
    VCR.use_cassette("#{@test_root_name}/cleanup") do
      status = TestModel.destroy!('instance_1')
      assert status == true
      status = TestModel.destroy!('instance_2')
      assert status == true
      status = TestModel.destroy!('instance_3')
      assert status == true
    end
  end
end
