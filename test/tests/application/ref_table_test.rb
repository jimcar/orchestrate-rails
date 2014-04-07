require_relative "../../test_helper"

class RefTableTest < MiniTest::Unit::TestCase

  include Test

  def setup
    @test_root_name = 'application/ref_table'
  end

  def setup_ref_table
    Orchestrate::Application::RefTable.enable
    Orchestrate::Rails::Schema.define_collection(
      :name           => 'orchio_ref_table',
      :classpath      => 'Test',
      :classname      => 'RefModel',
      :properties     => [ :xcollection, :xkey, :xref, :timestamp ],
    )
  end

  def purge_ref_table
    RefModel.all.each { |ref_instance| assert ref_instance.destroy! == true }
  end

  # The ref table (orchio_ref_table) should be updated with each successful
  # PUT request. The test executes a number of put requests, and then checks
  # the ref table.
  #
  def test_ref_table

    output_message(@test_root_name)

    setup_ref_table

    # setup
    output_message(@test_root_name, "Test setup")

    VCR.use_cassette("#{@test_root_name}/setup") do
      purge_ref_table
      assert RefModel.all.length == 0

      status = TestModel.destroy!('instance_1')
      assert status == true

      status = TestModel.destroy!('instance_2')
      assert status == true
    end

    # test
    output_message(@test_root_name, "TEST START")

    VCR.use_cassette("#{@test_root_name}/synopsis") do

      test_instance = TestModel.create!(id: 'instance_1', name: 'no_name')
      assert test_instance != false

      status = test_instance.update_attributes!(name: 'test_1', desc: 'The basics.')
      assert status != false
      assert RefModel.all.length == 2

      status = test_instance.update_attributes!(desc: 'The basics.')
      assert status != false
      assert RefModel.all.length == 2

      status = test_instance.update_attributes!(desc: 'The basics, plus some.')
      assert status != false
      assert RefModel.all.length == 3

      status = test_instance.update_attributes!(desc: 'The basics, plus some.')
      assert status != false
      assert RefModel.all.length == 3

      status = test_instance.update_attributes!(desc: 'The basics, plus even more...')
      assert status != false

      status = test_instance.update_attributes!(desc: 'The basics, plus lots, then we add the kitchen sink!')
      assert status != false

      assert RefModel.all.length == 5
      assert TestModel.all.length == 1

      test_instance = TestModel.create!(id: 'instance_2')
      assert test_instance != false

      status = test_instance.update_attribute!('name', 'test_2')
      assert status != false

      status = test_instance.update_attribute!('desc', 'desc_2')
      assert status != false

      assert TestModel.all.length == 2
      assert RefModel.all.length == 8
    end

    # cleanup
    output_message(@test_root_name, "Test cleanup")
    Orchestrate::Application::RefTable.disable

    VCR.use_cassette("#{@test_root_name}/cleanup") do
      purge_ref_table
      assert RefModel.all.length == 0

      status = TestModel.destroy!('instance_1')
      assert status == true

      status = TestModel.destroy!('instance_2')
      assert status == true
      assert TestModel.all.length == 0
    end
  end
end

class RefModel < Orchestrate::Rails::Model
  def initialize(params={})
    params[:define_collection_name] = 'orchio_ref_table'
    super params
  end
end
