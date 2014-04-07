require_relative "../../test_helper"

class RecordOrchioSearchTest < MiniTest::Unit::TestCase

  include Test

  def setup
    @test_root_name = 'application/orchio_search'
  end

  # class methods: orchio_search
  #
  def test_orchio_search

    output_message(@test_root_name)

    # setup
    VCR.use_cassette("#{@test_root_name}/setup") do
      status = TestModel.create!(id: 'instance_2', name: 'test_2a', desc: 'desc_2a')
      assert status != false
      status = TestModel.create!(id: 'instance_1', name: 'test_1a', desc: 'desc_1a')
      assert status != false
      status = TestModel.create!(id: 'instance_3', name: 'test_1a', desc: 'desc_2a')
      assert status != false
      sleep 1
    end

    # test
    VCR.use_cassette("#{@test_root_name}/synopsis") do
      test_documents = TestModel.orchio_search('test_models', '*').results
      assert test_documents.length == 3

      test_documents = TestModel.orchio_search('test_models', '*&offset=1').results
      assert test_documents.length == 2

      test_documents = TestModel.orchio_search('test_models', '*&offset=3').results
      assert test_documents.length == 0

      test_documents = TestModel.orchio_search('test_models', 'Name:TeSt_2a').results
      assert test_documents.length == 1
      assert test_documents.first.metadata.key == 'instance_2'

      test_documents = TestModel.orchio_search('test_models', 'DESC:desc_2*').results
      assert test_documents.length == 2

      test_documents = TestModel.orchio_search('test_models', 'DESC:desc_1*').results
      assert test_documents.length == 1
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
