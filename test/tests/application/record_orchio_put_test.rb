require_relative "../../test_helper"

class RecordOrchioPutTest < MiniTest::Unit::TestCase

  include Test

  def setup
    @test_root_name = 'application/orchio_put'
  end

  # instance methods: orchio_put, orchio_put_if_match, orchio_put_if_none_match
  #
  def test_orchio_put

    output_message(@test_root_name)

    etag = test_model = ref_model = ''

    # setup
    output_message(@test_root_name, "Test setup")

    VCR.use_cassette("#{@test_root_name}/setup") do
      status = TestModel.destroy('instance_1')
      assert status == true
    end

    # test
    output_message(@test_root_name, "TEST START")

    VCR.use_cassette("#{@test_root_name}/synopsis") do

      test_model = TestModel.new(id: 'instance_1')
      jdoc = { name: 'test_1a', desc: 'desc_1a' }.to_json
      status = test_model.orchio_put_if_none_match jdoc
      assert status != false

      jdoc = { name: 'test_1b', desc: 'desc_1b' }.to_json
      status = test_model.orchio_put_if_none_match jdoc
      assert status == false

      test_model = TestModel.new(id: 'instance_1')
      jdoc = { name: 'test_1c', desc: 'desc_1c' }.to_json
      status = test_model.orchio_put_if_match(jdoc, 'bogus-ref-value')
      assert status == false

      test_model = test_model.get
      jdoc = { name: 'test_b2', desc: 'desc_b2' }.to_json
      status = test_model.orchio_put_if_match(jdoc, test_model.orchestrate_ref_value)
      assert status != false

      test_model = TestModel.new(id: 'instance_1')
      jdoc = { name: 'test_1d', desc: 'desc_1d' }.to_json
      status = test_model.orchio_put_if_match(jdoc, test_model.orchestrate_ref_value)
      assert status == false

      test_model = TestModel.new(id: 'instance_1')
      jdoc = { name: 'test_1e', desc: 'desc_1e' }.to_json
      status = test_model.orchio_put(jdoc)
      assert status != false
    end

    # cleanup
    output_message(@test_root_name, "Test cleanup")

    VCR.use_cassette("#{@test_root_name}/cleanup") do
      status = TestModel.destroy!('instance_1')
      assert status == true
    end
  end
end
