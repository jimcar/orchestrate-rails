require_relative "../../test_helper"

class ModelGraphTest < MiniTest::Unit::TestCase

  include Test

  def setup
    @test_root_name = 'rails/graph'
  end

  # instance methods:  save_graph, graph
  #
  def test_graph

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
      graph_instances = test_instance_1.graph('add_100_or_more')
      assert graph_instances != nil
      assert graph_instances.length == 0

      graph_instance =
        test_instance_1.save_graph('add_100_or_more', 'test_models', 'instance_101')
      assert graph_instance != false
      assert graph_instance == test_instance_1

      graph_instance =
        test_instance_1.save_graph('add_100_or_more', 'test_models', 'instance_102')
      assert graph_instance != false
      assert graph_instance == test_instance_1

      graph_instance =
        test_instance_2.save_graph('add_100_or_more', 'test_models', 'instance_102')
      assert graph_instance != false
      assert graph_instance == test_instance_2

      graph_instance =
        test_instance_1.save_graph('add_99_or_less', 'test_models', 'instance_2')
      assert graph_instance != false
      assert graph_instance == test_instance_1

      graph_instance =
        test_instance_2.save_graph('add_99_or_less', 'test_models', 'instance_101')
      assert graph_instance != false
      assert graph_instance == test_instance_2

      graph_instances = test_instance_1.graph('add_100_or_more')
      assert graph_instances.length == 2

      graph_instances = test_instance_1.graph('add_99_or_less')
      assert graph_instances.length == 1

      graph_instances = test_instance_2.graph('add_100_or_more')
      assert graph_instances.length == 1

      graph_instances = test_instance_2.graph('add_99_or_less')
      assert graph_instances.length == 1

      status = test_instance_1.delete_graph('add_100_or_more', 'test_models', 'instance_101')
      assert status != false

      status = test_instance_1.delete_graph('add_100_or_more', 'test_models', 'instance_102')
      assert status != false

      status = test_instance_2.delete_graph('add_100_or_more', 'test_models', 'instance_102')
      assert status != false

      status = test_instance_1.delete_graph('add_99_or_less', 'test_models', 'instance_2')
      assert status != false

      status = test_instance_2.delete_graph('add_99_or_less', 'test_models', 'instance_101')
      assert status != false

      graph_instances = test_instance_1.graph('add_100_or_more')
      assert graph_instances != nil
      assert graph_instances.length == 0

      graph_instances = test_instance_2.graph('add_100_or_more')
      assert graph_instances != nil
      assert graph_instances.length == 0

      graph_instances = test_instance_1.graph('add_99_or_less')
      assert graph_instances != nil
      assert graph_instances.length == 0

      graph_instances = test_instance_1.graph('add_99_or_less')
      assert graph_instances != nil
      assert graph_instances.length == 0
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
