module Test

  module All

    # class methods: all, first, last, take
    #
    def test_all

      Test.setup_the_test
      test_root_name = 'rails/all'
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

        test_instances = TestModel.all
        assert test_instances.length == 3

        test_instance = TestModel.first
        assert test_instance != false
        assert test_instance.id == 'instance_1'
        assert test_instance.name == 'test_1a'
        assert test_instance.desc == 'desc_1a'

        test_instance = TestModel.last
        assert test_instance != false
        assert test_instance.id == 'instance_3'
        assert test_instance.name == 'test_1a'
        assert test_instance.desc == 'desc_2a'

        test_instance = TestModel.take
        assert test_instance != false
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