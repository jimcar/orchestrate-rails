require_relative "../../test_helper"

class ModelUpdateTest < MiniTest::Unit::TestCase

  include Test

  def setup
    @test_root_name = 'rails/update'
  end

  # instance methods: update_attribute,  update_attributes
  #                   update_attribute!, update_attributes!
  #
  def test_update

    output_message(@test_root_name)

    # setup
    VCR.use_cassette("#{@test_root_name}/setup") do
      status = TestModel.destroy('instance_1')
      assert status == true
      status = TestModel.destroy('instance_2')
      assert status == true
    end

    # test
    VCR.use_cassette("#{@test_root_name}/synopsis") do

      puts "\n        Test A1: update_attribute (put if-none-match) for test instance; should pass"
      test_model = TestModel.new(id: 'instance_1')
      status = test_model.update_attribute(:name, 'test_1')
      assert status != false
      assert test_model.id == 'instance_1'
      assert test_model.name == 'test_1'

      puts "\n        Test A2: update_attribute (put if-match) for test instance; should fail"
      test_model = TestModel.new(id: 'instance_1')
      status = test_model.update_attribute('name', 'test_1a')
      assert status == false

      puts "\n        Test A3: update_attribute! (put) for test instance; should pass"
      test_model = TestModel.new(id: 'instance_1')
      status = test_model.update_attribute!('name', 'test_1b')
      assert status != false
      assert test_model.id == 'instance_1'
      assert test_model.name == 'test_1b'

      puts "\n        Test D1: update_attributes (put if-none-match) for test instance; should pass"
      test_model = TestModel.new(id: 'instance_2')
      status = test_model.update_attributes(name: 'test_2', desc: 'desc_2')
      assert status != false
      assert test_model.id == 'instance_2'
      assert test_model.name == 'test_2'
      assert test_model.desc == 'desc_2'

      puts "\n        Test D2: update_attributes (put if-match) for test instance; should fail"
      test_model = TestModel.new(id: 'instance_2')
      status = test_model.update_attributes(name: 'test_2a', desc: 'desc_2a')
      assert status == false

      puts "\n        Test D3: update_attributes! (put) for test instance; should pass"
      test_model = TestModel.new(id: 'instance_2')
      status = test_model.update_attributes!(name: 'test_2c', desc: 'desc_2c')
      assert status != false
      assert test_model.id == 'instance_2'
      assert test_model.name == 'test_2c'
      assert test_model.desc == 'desc_2c'
    end

    # cleanup
    VCR.use_cassette("#{@test_root_name}/cleanup") do
      status = TestModel.destroy!('instance_1')
      assert status == true
      status = TestModel.destroy!('instance_2')
      assert status == true
    end
  end
end
