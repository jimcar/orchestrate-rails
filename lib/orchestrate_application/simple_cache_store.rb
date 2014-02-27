module Orchestrate::Application

  #  Class PrimaryKey
  #
  class PrimaryKey
    attr_reader :events, :graphs
    attr_accessor :ref

    def initialize(ref)
      # puts "SCC-primary_key: '#{ref}'"
      @ref = ref
      @events, @graphs = {}, {}
    end

    def add_event(etype, ref=nil)
      # puts "SCC-add event"
      @events[etype] = [] unless @events[etype]
      @events[etype] << ref if ref
      # puts "SCC-added event"
    end

    def add_graph(data)
      # puts "SCC-add graph: '#{data.kind}'"
      @graphs[data.kind] = [] unless @graphs[data.kind]
      @graphs[data.kind] << data.ref if data.ref
      # puts "SCC-added graph '#{@graphs[data.kind].last}'"
    end
  end


  #  Class SimpleCacheCollection
  #
  class SimpleCacheCollection

    attr_reader :name, :primary_keys, :events, :graphs

    def initialize(name)
      @name = name
      @primary_keys, @events, @graphs = {}, {}, {}
    end

    def flush!
      @primary_keys, @events, @graphs = {}, {}, {}
    end

    def fetch(key)
      # puts "SCC-fetching: '#{key}', '#{primary_keys[key]}'"
      if primary_keys[key]
        # puts "SCC-fetching: '#{primary_keys[key].ref}'"
        SimpleCacheRefs.instance.document primary_keys[key].ref
      end
    end

    def fetch_events(key, etype)
      # puts "SCC-fetch_events: '#{key}', '#{etype}'"
      if primary_keys[key] and primary_keys[key].events[etype]
        primary_keys[key].events[etype].map { |ref|
          # puts "SCC-fetch_events: '#{ref}'"
          SimpleCacheRefs.instance.document ref
        }
      end
    end

    def fetch_graph(key, kind)
      # puts "SCC-fetch_graph 1: '#{key}', '#{kind}'"
      if primary_keys[key] and primary_keys[key].graphs and primary_keys[key].graphs[kind]
        primary_keys[key].graphs[kind].map { |ref|
          # puts "SCC-fetch_graph: '#{ref}'"
          SimpleCacheRefs.instance.document ref
        }
      end
    end

    def get_ref(key)
      primary_keys[key] and primary_keys[key].ref
    end

    def save(data)
      key, ref = data.key, data.ref
      @primary_keys[key] = PrimaryKey.new(ref) if primary_keys[key].nil?
      if data.respond_to? :etype and data.etype
        @primary_keys[key].add_event(data.etype, ref)
      else
        @primary_keys[key].ref = ref
      end
    end

    def save_event(data)
      @primary_keys[data.key] = PrimaryKey.new(0) if primary_keys[data.key].nil?
      @primary_keys[data.key].add_event data.etype
    end

    def save_graph(data)
      @primary_keys[data.from_key] = PrimaryKey.new(0) if primary_keys[data.from_key].nil?
      @primary_keys[data.from_key].add_graph data
    end


  end

  # Stores documents in cache, indexed by ref value.
  #
  class SimpleCacheRefs
    include Singleton

    def initialize
      @@documents = {}
    end

    def save(ref, document)
      @@documents[ref] = document
    end

    def document(ref)
      @@documents[ref]
    end

    def flush!
      @@documents = {}
    end
  end

  #  When enabled, the cache mechanism:
  #  * is useful for development/testing, minimizing calls to the server.
  #  * is updated upon each GET or PUT request.
  #  * remains active for the lifespan of the application.
  #
  class SimpleCacheStore

    def initialize
      @@is_enabled ||= false
      @@cache ||= simple_cache_init
      # puts "SC-init: cache -> '#{@@cache}', '#{!@@cache.nil?}'"
      @@refs ||= {}
    end

    def simple_cache_init
      cache = Hash[Schema.instance.collection_names.map { |name|
        [name, SimpleCacheCollection.new(name)]
      }]
      # puts "SC-sc_init -> '#{cache}', is_enabled -> '#{@@is_enabled}'"
      cache == {} ? nil : cache
    end

    def self.instance
      @@cache ||= @@instance.simple_cache_init
      @@instance
    end

    def self.enable
      # puts "SC-ENABLE"
      # @@is_enabled = true
      puts "SIMPLE-CACHE has been DISABLED for the current version."
    end

    def self.disable
      puts "SC-DISABLE"
      @@is_enabled = false
    end

    @@instance = SimpleCacheStore.new
    private_class_method :new

    # -------------------------------------------------------------------------

    #
    def cache
      @@cache
    end

    def flush!(collection=nil)
      if collection
        get_cc(collection).flush!
      else
        @@cache = simple_cache_init
      end
    end

    def get_cache_collection(name)
      cache[name]
    end

    def get_cc(name)
      get_cache_collection name
    end

    def save(document)
      m = document.metadata
      get_cc(m.from_collection).save_graph(m) if m.respond_to? :kind and m.kind
      get_cc(m.collection).save m
      SimpleCacheRefs.instance.save m.ref, document
    end

    def get_ref(collection_name, key)
      get_cc(collection_name).get_ref key
    end

    def fetch(collection, key)
      get_cc(collection).fetch(key)
    end

    def is_enabled?
      @@is_enabled
    end

    def enable
      self.class.enable
    end

    def disable
      self.class.disable
    end

  end
end
