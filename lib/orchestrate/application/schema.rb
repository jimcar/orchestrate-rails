module Orchestrate::Application

  # ---------------------------------------------------------------------------
  #  Singleton class to define schema for Orchestrate.io application
  #
  class Schema < Object
    include Singleton

    def initialize
      @@schema = {}
    end

    def schema
      @@schema
    end

    def collections
      schema
    end

    def collection_names
      schema.keys
    end

    def get(collection_name)
      schema[collection_name]
    end

    def get_collection(name)
      get(name)
    end

    def load_collection(collection)
      schema[collection.name] = collection
    end

    def define_collection(args)
      load_collection SchemaCollection.new(args)
    end

    def define_event_type(collection_name, event_type, properties)
      get(collection_name).define_event_type event_type, properties
    end

    def define_graph(collection_name, relation_kind, to_collection)
      get(collection_name).define_graph relation_kind, to_collection
    end

    #  Support (optional) loading of schema from a definition file
    #
    #  Example usage:
    #
    #     Orchestrate::Application::Schema.instance.load "./schema.rb"
    #
    #  Example definition file - i.e. "<APP-ROOT>/schema.rb"
    #
    #     Orchestrate::Application::Schema.instance.define_collection(
    #       :name           => 'films',
    #       :properties     => [ :Title, :Year, :Rated, :Released,
    #                            :Runtime, :Genre, :Director, :Writer,
    #                            :Actors, :Plot, :Poster, :imdbRating,
    #                            :imdbVotes, :imdbID, :Type, :Response ],
    #       :event_types    => [ :comments ],
    #       :graphs         => [ :sequel ],
    #     )
    #
    #     Orchestrate::Application::Schema.instance.define_event_type(
    #       :collection => 'films',
    #       :event_type => :comments,
    #       :properties => [ :User, :Comment ]
    #     )
    #
    #     Orchestrate::Application::Schema.instance.define_graph(
    #       :collection    => 'films',
    #       :relation_kind => :sequel,
    #       :to_collection => 'films',
    #     )
    #
    def load(schema)
      require schema
    end
  end

end

