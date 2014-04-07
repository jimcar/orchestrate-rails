require_relative "../../test_helper"

class ModelSaveTest < MiniTest::Unit::TestCase

  include Test

  def setup
    @test_root_name = 'rails/save'
  end

  # instance methods: save_if_none_match, save (save_if_match),  save!
  #
  def test_save

    output_message(@test_root_name)

    etag = test_model = ref_model = ''

    # setup
    VCR.use_cassette("#{@test_root_name}/setup") do
      status = TestModel.destroy('instance_1')
      assert status == true
    end

    # test
    VCR.use_cassette("#{@test_root_name}/synopsis") do

      puts "\n        Test A1: save_if_none_match (put if-none-match) new test instance; should pass"
      test_model = TestModel.new(id: 'instance_1', name: 'test_1a', desc: 'desc_1a')
      status = test_model.save_if_none_match
      assert status != false
      assert test_model.id == 'instance_1'
      assert test_model.name == 'test_1a'
      assert test_model.desc == 'desc_1a'

      puts "\n        Test A2: save_if_none_match (put if-none-match) new test instance; should fail"
      test_model = TestModel.new(id: 'instance_1', name: 'test_1b', desc: 'desc_1b')
      status = test_model.save_if_none_match
      assert status == false

      puts "\n        Test B1: save (put if-match) for same test instance; should fail"
      test_model = TestModel.new(id: 'instance_1', name: 'test_1c', desc: 'desc_1c')
      status = test_model.save
      assert status == false

      puts "\n        Test B2: save (put if-match) for same test instance; should pass"
      test_model = TestModel.find('instance_1')
      test_model.name = 'test_b2'
      test_model.desc = 'desc_b2'
      status = test_model.save
      assert status != false
      assert test_model.id == 'instance_1'
      assert test_model.name == 'test_b2'
      assert test_model.desc == 'desc_b2'

      puts "\n        Test B3: save (put if-match) for same test instance; should fail"
      test_model = TestModel.new(id: 'instance_1', name: 'test_1d', desc: 'desc_1d')
      status = test_model.save
      assert status == false

      puts "\n        Test B4: save! (put) for same test instance; should pass"
      test_model = TestModel.new(id: 'instance_1', name: 'test_1e', desc: 'desc_1e')
      status = test_model.save!
      assert status != false
    end

    # cleanup
    VCR.use_cassette("#{@test_root_name}/cleanup") do
      status = TestModel.destroy!('instance_1')
      assert status == true
    end
  end
end
