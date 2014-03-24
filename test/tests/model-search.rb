module Test

  module Search

    # class methods: search, search_results
    #
    def test_search

      Test.setup_the_test
      test_root_name = 'rails/search'
      Test.output_message(test_root_name)

      # setup
      VCR.use_cassette("#{test_root_name}/setup") do
        status = TestModel.create!(id: 'instance_2', name: 'test_2a', desc: 'desc_2a')
        assert status != false
        status = TestModel.create!(id: 'instance_1', name: 'test_1a', desc: 'desc_1a')
        assert status != false
        status = TestModel.create!(id: 'instance_3', name: 'test_1a', desc: 'desc_2a')
        assert status != false
        sleep 1
      end

      # test
      VCR.use_cassette("#{test_root_name}/synopsis") do
        test_instances = TestModel.search('*').results
        assert test_instances.length == 3

        test_instances = TestModel.search('*', :all, 1).results
        assert test_instances.length == 2

        test_instances = TestModel.search('*', :all, 3).results
        assert test_instances.length == 0

        test_instances = TestModel.search('name:TeSt_2a').results
        assert test_instances.length == 1
        assert test_instances.first.id == 'instance_2'

        test_instances = TestModel.search('desc:desc_2*').results
        assert test_instances.length == 2

        test_instances = TestModel.search('DESC:desc_1*').results
        assert test_instances.length == 1

        test_instances = TestModel.search_results('name:test_*')
        assert test_instances.length == 3

        test_instances = TestModel.search_results('name:fred')
        assert test_instances.length == 0
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