require_relative "../../test_helper"

class RecordOrchioGraphTest < MiniTest::Unit::TestCase

  include Test

  def setup
    @test_root_name = 'application/orchio_graph'
  end

  # instance methods: orchio_put_graph, orchio_get_graph
  #
  def test_orchio_graph

    output_message(@test_root_name)

    test_instance_1 = test_instance_2 = nil

    # setup
    VCR.use_cassette("#{@test_root_name}/setup") do
      status = TestModel.destroy!('instance_1')
      assert status == true
      status = TestModel.destroy!('instance_2')
      assert status == true
      status = TestModel.destroy!('instance_101')
      assert status == true
      status = TestModel.destroy!('instance_102')
      assert status == true

      test_instance_1 = TestModel.create!(id: 'instance_1', name: 'test_1a', desc: 'desc_1a')
      assert test_instance_1 != false
      test_instance_2 = TestModel.create!(id: 'instance_2', name: 'test_2a', desc: 'desc_2a')
      assert test_instance_2 != false
      test_instance_3 = TestModel.create!(id: 'instance_101', name: 'test_101', desc: 'desc_101')
      assert test_instance_3 != false
      test_instance_4 = TestModel.create!(id: 'instance_102', name: 'test_102', desc: 'desc_102')
      assert test_instance_4 != false
    end

    # test
    VCR.use_cassette("#{@test_root_name}/synopsis") do

      # ---------------------------------

      graph_result = test_instance_1.orchio_get_graph('add_100_or_more')
      assert graph_result.results.length == 0

      status = test_instance_1.orchio_put_graph('add_100_or_more', 'test_models', 'instance_101')
      assert status == true

      status = test_instance_1.orchio_put_graph('add_100_or_more', 'test_models', 'instance_102')
      assert status == true

      graph_result = test_instance_1.orchio_get_graph('add_100_or_more')
      assert graph_result.results.length == 2

      # ---------------------------------

      graph_result = test_instance_1.orchio_get_graph('add_99_or_less')
      assert graph_result.results.length == 0

      status = test_instance_1.orchio_put_graph('add_99_or_less', 'test_models', 'instance_2')
      assert status == true

      graph_result = test_instance_1.orchio_get_graph('add_99_or_less')
      assert graph_result.results.length == 1

      # ---------------------------------

      graph_result = test_instance_2.orchio_get_graph('add_100_or_more')
      assert graph_result.results.length == 0

      status = test_instance_2.orchio_put_graph('add_100_or_more', 'test_models', 'instance_102')
      assert status == true

      graph_result = test_instance_2.orchio_get_graph('add_100_or_more')
      assert graph_result.results.length == 1

      # ---------------------------------

      graph_result = test_instance_2.orchio_get_graph('add_99_or_less')
      assert graph_result.results.length == 0

      status = test_instance_2.orchio_put_graph('add_99_or_less', 'test_models', 'instance_101')
      assert status == true

      graph_result = test_instance_2.orchio_get_graph('add_99_or_less')
      assert graph_result.results.length == 1

      # ---------------------------------

      status = test_instance_1.orchio_delete_graph('add_100_or_more', 'test_models', 'instance_101')
      assert status == true

      graph_result = test_instance_1.orchio_get_graph('add_100_or_more')
      assert graph_result.results.length == 1

      status = test_instance_1.orchio_delete_graph('add_100_or_more', 'test_models', 'instance_102')
      assert status == true

      graph_result = test_instance_1.orchio_get_graph('add_100_or_more')
      assert graph_result.results.length == 0

      # ---------------------------------

      status = test_instance_1.orchio_delete_graph('add_99_or_less', 'test_models', 'instance_2')
      assert status == true

      graph_result = test_instance_1.orchio_get_graph('add_99_or_less')
      assert graph_result.results.length == 0

      # ---------------------------------

      status = test_instance_2.orchio_delete_graph('add_100_or_more', 'test_models', 'instance_102')
      assert status == true

      graph_result = test_instance_2.orchio_get_graph('add_100_or_more')
      assert graph_result.results.length == 0

      # ---------------------------------

      status = test_instance_2.orchio_delete_graph('add_99_or_less', 'test_models', 'instance_101')
      assert status == true

      graph_result = test_instance_2.orchio_get_graph('add_99_or_less')
      assert graph_result.results.length == 0

    end

    # cleanup
    VCR.use_cassette("#{@test_root_name}/cleanup") do
      status = TestModel.destroy!('instance_1')
      assert status == true
      status = TestModel.destroy!('instance_2')
      assert status == true
      status = TestModel.destroy!('instance_101')
      assert status == true
      status = TestModel.destroy!('instance_102')
      assert status == true
    end
  end
end
