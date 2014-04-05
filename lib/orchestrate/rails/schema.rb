module Orchestrate::Rails

  #  Rails-specific extensions to parent class.
  #
  class SchemaCollection < Orchestrate::Application::SchemaCollection
    attr_accessor :attr_map, :qmap, :classname, :classpath
  end

  # Extensions to parent class for mapping data between orchestrate and rails.
  #
  class Schema < Orchestrate::Application::Schema
    include Singleton

    def properties(collection_name)
      get_collection(collection_name).properties
    end

    def attrs(collection_name)
      get_collection(collection_name).attr_map.keys
    end

    # Returns the table that maps attribute names to property names.
    #
    # Property names are the original key names in json documents stored
    # in orchestrate collections - before they are converted to the snake_case
    # style used for model attribute names. Property names can be mapped to
    # attribute names by using ::String#to_orchio_rails_attr or
    # ::Symbol#to_orchio_rails_attr.
    def attr_map(collection_name)
      get_collection(collection_name).attr_map
    end

    # Returns a table that maps attribute names to property names. And the
    # mapping conveniently works even when the attribute name is actually
    # a property name.
    def qmap(collection_name)
      get_collection(collection_name).qmap ||= build_query_map(collection_name)
    end

    def classname(collection_name)
      get_collection(collection_name).classname
    end

    def fullclassname(collection_name)
      c = get_collection(collection_name)
      c.classpath.nil? ? c.classname : "#{c.classpath}::#{c.classname}"
    end

    def get_collection_from_class(classname)
      classname = classname.split('::').last
      collections.values.each { |c| return c if c.classname == classname }
    end

    def build_query_map(collection)
      q_map = {}
      attr_map(collection).values.map { |a|
        q_map.merge!(a => a, a.to_orchio_rails_attr => a)
      }.last
    end
    private :build_query_map

    # -------------------------------------------------------------------------
    #  Class methods to facilitate loading schema definition at rails startup,
    #  via definition file 'db/schema.rb' loaded in 'config/application.rb.'

    #
    def self.load(schema)
      require Rails.root.join schema
    end

    # args: { :name, :properties, :event_types, :graphs, :classname }
    #
    def self.define_collection(args)
      # puts "DEF_COLL: '#{args.inspect}'"
      coll = instance.load_collection SchemaCollection.new(args) { |c|
        c.classname = args[:classname]
        c.classpath = args[:classpath] #unless args[:classpath].blank?
        c.attr_map = build_attr_map args[:properties]
      }
      # puts "DEF_COLL: '#{coll.classpath}'"
    end

    def self.define_event_type(args)
      # puts "DEFINE: inst = '#{instance}', '#{args[:collection]}'"  #JMC
      instance.define_event_type(
        args[:collection], args[:event_type], args[:properties]
      )
    end

    def self.define_graph(args)
      instance.define_graph(
        args[:collection], args[:relation_kind], args[:to_collection]
      )
    end

    private
      def self.build_attr_map(attrs)
        attr_map = {}
        attrs.map { |a| attr_map.merge!(a.to_orchio_rails_attr => a.to_s) }.last
      end
  end

end

