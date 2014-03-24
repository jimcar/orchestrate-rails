module Test

  module OrchioList

    # class methods: orchio_list
    #
    def test_orchio_list

      Test.setup_the_test
      test_root_name = 'application/orchio_list'
      Test.output_message(test_root_name)

      # setup
      VCR.use_cassette("#{test_root_name}/setup") do
        status = TestModel.create!(id: 'instance_2', name: 'test_2a', desc: 'desc_2a')
        assert status != false
        status = TestModel.create!(id: 'instance_1', name: 'test_1a', desc: 'desc_1a')
        assert status != false
        status = TestModel.create!(id: 'instance_3', name: 'test_1a', desc: 'desc_2a')
        assert status != false
      end

      # test
      VCR.use_cassette("#{test_root_name}/synopsis") do

        test_documents = TestModel.orchio_list('test_models').results
        assert test_documents.length == 3

        test_documents = TestModel.orchio_list('test_models', "?limit=2").results
        assert test_documents.length == 2

        # test_documents = TestModel.list(0).results
        # assert test_documents.length == 0

        max = 100

        test_documents =
          TestModel.orchio_list('test_models', "?limit=#{max}&startKey=instance_3").results
        assert test_documents.length == 1

        test_documents =
          TestModel.orchio_list('test_models', "?limit=#{max}&startKey=instance_2").results
        assert test_documents.length == 2

        test_documents =
          TestModel.orchio_list('test_models', "?limit=1&afterKey=instance_2").results
        assert test_documents.length == 1

        test_documents =
          TestModel.orchio_list('test_models', "?limit=#{max}&afterKey=instance_3").results
        assert test_documents.length == 0

        test_documents =
          TestModel.orchio_list('test_models', "?limit=#{max}&afterKey=instance_1").results
        assert test_documents.length == 2
      end

      # cleanup
      VCR.use_cassette("#{test_root_name}/cleanup") do
        status = TestModel.destroy!('instance_1')
        assert status == true
        status = TestModel.destroy!('instance_2')
        assert status == true
        status = TestModel.destroy!('instance_3')
        assert status == true
      end
    end
  end
end