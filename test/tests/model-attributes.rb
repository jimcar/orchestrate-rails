module Test

  module Attributes

    # class methods:  attributes, attrs, properties, qmap
    #
    # instance methods: attributes, attrs,
    #                   read_attribute_for_serialization
    #                   read_attribute_for_validation
    #
    # monkey-patched methods: ::Symbol#to_orchio_rails_attr
    #                         ::String#to_orchio_rails_attr
    #
    def test_attributes

      Test.setup_the_test
      test_root_name = 'rails/attributes'
      Test.output_message(test_root_name)

      test_instance = nil

      # setup
      VCR.use_cassette("#{test_root_name}/setup") do
        test_instance = TestModel.create!(id: 'instance_1', name: 'test_1a', desc: 'desc_1a')
        assert test_instance != false
      end

      # test
      VCR.use_cassette("#{test_root_name}/synopsis") do

        test_props = TestModel.properties
        assert test_props.length == 2
        assert test_props.include? :Name
        assert test_props.include? :DESC

        test_attrs = TestModel.attrs
        assert test_attrs.length == 2
        assert test_attrs.include? 'name'
        assert test_attrs.include? 'desc'

        test_attrs = test_instance.attrs
        assert test_attrs.length == 2
        assert test_attrs.include? 'name'
        assert test_attrs.include? 'desc'

        test_attributes = test_instance.attributes
        assert test_attributes.length == 2
        assert test_attributes.include? :name
        assert test_attributes.include? :desc
        assert test_attributes[:name] == 'test_1a'
        assert test_attributes[:desc] == 'desc_1a'

        test_qmap = TestModel.qmap
        assert test_qmap.length == test_props.length + test_attrs.length

        test_attrs.each { |a| assert test_qmap.include? a }

        test_props.each do |p|
          assert test_qmap.include? p.to_s
          assert test_qmap.include? p.to_orchio_rails_attr
        end

        test_qmap.each do |k,v|
          assert test_attrs.include? k.to_orchio_rails_attr
          assert test_props.include? v.to_sym
        end

        assert test_instance.read_attribute_for_serialization(:name) == 'test_1a'
        assert test_instance.read_attribute_for_validation(:desc) == 'desc_1a'

        assert test_instance.read_attribute_for_serialization(:bogus).nil?
        assert test_instance.read_attribute_for_validation(:bogus).nil?
      end

      # cleanup
      VCR.use_cassette("#{test_root_name}/cleanup") do
        status = TestModel.destroy!('instance_1')
        assert status == true
      end
    end
  end
end