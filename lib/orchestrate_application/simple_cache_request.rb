 module Orchestrate::Application

  class SimpleCacheRequest
    attr_reader :collection

    def initialize(collection)
      # puts "CACHE-init: '#{collection}'"
      @collection = collection
      @@cache_store ||= SimpleCacheStore.instance
    end

    def enabled?
      cache.is_enabled?
    end

    def get(key)
      doc = cache.get_cc(collection).fetch key
      path = "/local_cache/#{collection}/#{key}"
      puts "\n------- GET \"#{path}\" ------ #{doc ? 'OK' : 'not found'}"
      response([doc]) if doc
    end

    def get_graph(key, kind)
      docs = cache.get_cc(collection).fetch_graph key, kind
      path = "/local_cache/#{collection}/#{key}/graph/#{kind}"
      puts "\n------- GET \"#{path}\" ------ #{docs ? 'OK' : 'not found'}"
      response(docs) if docs
    end

    def save_graph(key, kind)
      cache.get_cc(collection).save_graph Metadata.new(from_key: key, kind: kind)
    end

    def get_events(key, event_type)
      docs = cache.get_cc(collection).fetch_events key, event_type
      path = "/local_cache/#{collection}/#{key}/events/#{event_type}"
      puts "\n------- GET \"#{path}\" ------ #{docs ? 'OK' : 'not found'}"
      response(docs) if docs
    end

    def save_event(key, event_type)
      cache.get_cc(collection).save_event Metadata.new(key: key, etype: event_type)
    end

    private

      def cache
        @@cache_store
      end

      def response(docs)
        locations = docs.map { |doc|
          location = "/local_cache/refs/#{doc.id}"
          puts "          from \"#{location}\""
          location
        }
        r_info = { locations: locations, code: 200, :status => :cache }
        r_info.merge!(etag: docs.first.id) if docs.length == 1
        SimpleCacheResponse.new(r_info, docs)
      end
  end
end