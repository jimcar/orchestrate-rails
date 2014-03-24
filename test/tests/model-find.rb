module Test

  module Find

    # class methods: exists?, find, find_by, find_by_method, where
    #
    def test_find

      Test.setup_the_test
      test_root_name = 'rails/find'
      Test.output_message(test_root_name)

      # setup
      VCR.use_cassette("#{test_root_name}/setup") do
        status = TestModel.create!(id: 'instance_1', name: 'test_1a', desc: 'desc_1a')
        assert status != false
        status = TestModel.create!(id: 'instance_2', name: 'test_2a', desc: 'desc_2a')
        assert status != false
        status = TestModel.create!(id: 'instance_3', name: 'test_1a', desc: 'desc_2a')
        assert status != false
      end

      # test
      VCR.use_cassette("#{test_root_name}/synopsis") do

        status = TestModel.exists?('instance_1')
        assert status == true

        status = TestModel.exists?('instance_100')
        assert status == false

        test_instance = TestModel.find('instance_1')
        assert test_instance != false
        assert test_instance.name == 'test_1a'
        assert test_instance.desc == 'desc_1a'

        test_instance = TestModel.find('instance_100')
        assert test_instance == false

        test_instance = TestModel.find_by(name: 'test_2a', desc: 'desc_2a')
        assert test_instance != false
        assert test_instance.id == 'instance_2'
        assert test_instance.name == 'test_2a'
        assert test_instance.desc == 'desc_2a'

        test_instance = TestModel.find_by(name: 'test_100a', desc: 'desc_1a')
        assert test_instance.nil?

        test_instance = TestModel.find_by_name_and_desc('test_1a', 'desc_1a')
        assert test_instance != false
        assert test_instance.id == 'instance_1'
        assert test_instance.name == 'test_1a'
        assert test_instance.desc == 'desc_1a'

        # test_instance = TestModel.find_by_name_and_desc('test_4a', 'desc_4a')
        # assert test_instance.nil?

        test_instances = TestModel.where(name: 'test_1a')
        assert !test_instances.nil?
        assert test_instances.length == 2

        test_instances = TestModel.where(name: 'test_1a', desc: 'desc_2a')
        assert !test_instances.nil?
        assert test_instances.length == 1

        test_instances = TestModel.where(name: 'test_2a', desc: 'desc_1a')
        assert !test_instances.nil?
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