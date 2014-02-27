module Orchestrate::Application

  # Object to encapsulate the key/value data along with the metadata
  # associated with an Orchestrate.io record. Used to return results
  # from the application layer.
  #
  class Document < Object

    # Metadata.
    attr_reader :metadata

    # The key/value data for this record.
    attr_reader :key_value_pairs

    # The <tt>ref</tt> value associated with the document.
    attr_reader :id

    # Saves the key/value data and Metadata. Saves the doc to cache
    # when cache is enabled.
    def initialize(key_value_pairs, metadata)
      @key_value_pairs = key_value_pairs
      @metadata = metadata
      @id = @metadata.ref

      save if cache_enabled?
    end

    # Saves the document to cache.
    def save
      # puts "DOC: saving -> '#{cache}'"
      # puts "     respond_to? :save -> '#{cache.respond_to? :save}'"
      cache.save self
      # puts "DOC: saved"
    end

    # Returns handle to the SimpleCacheStore singleton instance.
    def cache
      @@cache ||= SimpleCacheStore.instance
    end

    def cache_enabled?
      cache.is_enabled?
    end
  end

  # Holds the metadata associated with each document in the results
  # from a GET request.
  class Metadata < Object

    # For all documents, the metadata includes:
    # - collection
    # - key
    # - ref
    # and the following for specific result types:
    # - score (search)
    # - etype (events)
    # - kind, from_collection and from_key (graph)
    def initialize(metadata)
      metadata.each do |k,v|
        self.class.send :attr_reader, k.to_s
        instance_variable_set "@#{k.to_s}", v
      end
    end
  end

end