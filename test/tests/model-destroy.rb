module Test

  module Destroy

    # class methods: destroy, destroy!, destroy_all
    #
    # instance methods: destroy, destroy!
    #
    def test_destroy

      Test.setup_the_test
      test_root_name = 'rails/destroy'
      Test.output_message(test_root_name)

      ref_value_1a = ref_value_1b = ref_value_1c = nil
      ref_value_4a = ref_value_4b = ref_value_4c = nil

      # setup
      VCR.use_cassette("#{test_root_name}/setup") do

        test_instance = TestModel.create!(id: 'instance_1', name: 'test_1a', desc: 'desc_1a')
        assert test_instance != false
        ref_value_1a = test_instance.orchestrate_ref_value

        status = test_instance.update_attributes!(name: 'test_1b', desc: 'desc_1b')
        assert status != false
        ref_value_1b = test_instance.orchestrate_ref_value
        assert ref_value_1b != ref_value_1a

        status = test_instance.update_attributes!(name: 'test_1c', desc: 'desc_1c')
        assert status != false
        ref_value_1c = test_instance.orchestrate_ref_value
        assert ref_value_1c != ref_value_1a
        assert ref_value_1c != ref_value_1b

        test_instance = TestModel.create!(id: 'instance_4', name: 'test_4a', desc: 'desc_4a')
        assert test_instance != false
        ref_value_4a = test_instance.orchestrate_ref_value

        status = test_instance.update_attributes!(name: 'test_4b', desc: 'desc_4b')
        assert status != false
        ref_value_4b = test_instance.orchestrate_ref_value
        assert ref_value_4b != ref_value_4a

        status = test_instance.update_attributes!(name: 'test_4c', desc: 'desc_4c')
        assert status != false
        ref_value_4c = test_instance.orchestrate_ref_value
        assert ref_value_4c != ref_value_4a
        assert ref_value_4c != ref_value_4b

        test_instance = TestModel.create!(id: 'instance_2', name: 'test_2a', desc: 'desc_2a')
        assert test_instance != false

        test_instance = TestModel.create!(id: 'instance_3', name: 'test_3a', desc: 'desc_3a')
        assert test_instance != false
      end

      # test
      VCR.use_cassette("#{test_root_name}/synopsis") do
        status = TestModel.destroy('instance_4')
        assert status == true
        assert TestModel.all.length == 3

        status = TestModel.find('instance_4')
        assert status == false

        ref_instance = TestModel.new(id: 'instance_4').get_by_ref(ref_value_4a)
        assert ref_instance != false
        assert ref_instance.id == 'instance_4'
        assert ref_instance.name == 'test_4a'
        assert ref_instance.desc == 'desc_4a'

        status = TestModel.destroy!('instance_4')
        assert status == true

        ref_instance = TestModel.new(id: 'instance_4').get_by_ref(ref_value_4a)
        assert ref_instance == false

        test_instance = TestModel.new(id: 'instance_1')
        status = test_instance.destroy
        assert status == true
        assert TestModel.all.length == 2

        status = test_instance.get
        assert status == false

        ref_instance = test_instance.get_by_ref(ref_value_1a)
        assert ref_instance != nil
        assert ref_instance.id == 'instance_1'
        assert ref_instance.name == 'test_1a'
        assert ref_instance.desc == 'desc_1a'

        ref_instance = test_instance.get_by_ref(ref_value_1b)
        assert ref_instance != nil
        assert ref_instance.id == 'instance_1'
        assert ref_instance.name == 'test_1b'
        assert ref_instance.desc == 'desc_1b'

        ref_instance = test_instance.get_by_ref(ref_value_1c)
        assert ref_instance != false
        assert ref_instance.id == 'instance_1'
        assert ref_instance.name == 'test_1c'
        assert ref_instance.desc == 'desc_1c'

        status = test_instance.destroy!
        assert status == true

        ref_instance = test_instance.get_by_ref(ref_value_1a)
        assert ref_instance == false

        ref_instance = test_instance.get_by_ref(ref_value_1b)
        assert ref_instance == false

        ref_instance = test_instance.get_by_ref(ref_value_1c)
        assert ref_instance == false

        status = TestModel.destroy_all
        assert status == true
        sleep 1
        assert TestModel.all.length == 0
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