Orchestrate::Rails::Schema.define_collection(
  :name           => 'test_models',
  :classpath      => 'Test',
	:classname      => 'TestModel',
  :properties     => [ :Name, :DESC ],
  :event_types    => [ :test_event ],
  :graphs         => [ :test_graph ],
)

Orchestrate::Rails::Schema.define_event_type(
  :collection => 'test_models',
  :event_type => 'test_event',
  :properties => [ :Name, :ConTentS ]
)

Orchestrate::Rails::Schema.define_graph(
  :collection    => 'test_models',
  :relation_kind => :test_graph,
  :to_collection => 'test_collection',
)

