module Orchestrate::Application

  # Schema support object.
  #
  class SchemaCollection < Object
    attr_reader :name, :properties, :event_types, :graphs

    # args: { :name, :properties, :event_types, :graphs }
    #
    def initialize(args)
      @name, @properties = args[:name], args[:properties] + [:id]

      @event_types = {}
      if args[:event_types]
        args[:event_types].each { |etype| @event_types[etype] = etype }
      end

      @graphs = {}
      if args[:graphs]
        args[:graphs].each { |kind| @graphs[kind] = kind }
      end

      yield self if block_given?
    end

    def define_event_type(event_type, properties)
     @event_types[event_type] = SchemaEventType.new(event_type, properties)
    end

    def define_graph(relation_kind, to_collection)
      @graphs[relation_kind] = SchemaGraph.new(relation_kind, to_collection)
    end
  end

  # Schema support object.
  #
  class SchemaEventType
    attr_reader :name, :properties
    def initialize(event_type, properties)
      @name, @properties = event_type, properties
    end
  end

  # Schema support object.
  #
  class SchemaGraph
    attr_reader :kind, :to_collection
    def initialize(kind, to_collection)
      @kind, @to_collection = kind, to_collection
    end
  end

end