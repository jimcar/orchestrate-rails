require_relative "../../test_helper"

class ModelCreateTest < MiniTest::Unit::TestCase

  include Test

  def setup
    @test_root_name = 'rails/create'
  end

  # class methods: create, create!
  #
  def test_create

    output_message(@test_root_name)

    etag = test_model = ref_model = ''

    # setup
    VCR.use_cassette("#{@test_root_name}/setup") do
      status = TestModel.destroy('instance_1')
      assert status == true
    end

    # test
    VCR.use_cassette("#{@test_root_name}/synopsis") do

      puts "\n        Test B1: create (put if-none-match) test instance; should pass"
      test_model = TestModel.create(id: 'instance_1', name: 'test_1a', desc: 'desc_1a')
      assert test_model != false
      assert test_model.id == 'instance_1'
      assert test_model.desc == 'desc_1a'
      etag = test_model.orchestrate_ref_value

      puts "\n        Test C1: create (put if-none-match) test instance again; should fail"
      test_model = TestModel.create(id: 'instance_1', name: 'test_1b', desc: 'desc_1b')
      assert test_model == false

      puts "\n        Test D1: create! (put) test instance again; should pass"
      test_model = TestModel.create!(id: 'instance_1', name: 'test_1c', desc: 'desc_1c')
      assert test_model != false
      assert test_model.id == 'instance_1'
      assert test_model.desc == 'desc_1c'
    end

    # cleanup
    VCR.use_cassette("#{@test_root_name}/cleanup") do
      status = TestModel.destroy!('instance_1')
      assert status == true
    end
  end
end