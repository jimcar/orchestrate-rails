module Orchestrate::Application

  require "active_support/core_ext"

  # Class for accessing collections belonging to an Orchestrate.io application.
  # - public class methods for collection requests
  # - public instance methods for key/value requests
  #
  # PUT and DELETE requests return
  # <b>{Orchestrate::API::Response}[../API/Response.html]</b>.
  #
  # GET requests return <b>Result[Result.html]</b> or
  # <b>SearchResult[SearchResult.html]</b>.
  # The result data is returned as <b>Document[Document.html]</b> objects.
  #
  class Record < Object

    # The unique primary_key that identifies a set of key/value data
    # stored in an orchestrate.io collection.
    attr_reader :id

    # attr_reader :event_types, :graphs

    # :stopdoc:
    # The <b>ref</b> value for the current instance.
    # Convenience method #orchestrate_ref_value is provided as the
    # recommended way for an application to read this attribute.
    attr_reader :__ref_value__
    # :startdoc:

    @@_collection = {}
    @@_cache = {}

    # Performs application-level initialization functions.
    def initialize(params={})
      name = init_collection_name params[:define_collection_name]
      @@_collection[self.class.name] ||= Schema.instance.get_collection(name)
      @id = params[:id] if params[:id]
      @__ref_value__ = '"*"'

      # @event_types = params[:event_types] ? params[:event_types] : []
      # @relation_kinds = params[:graphs] ? params[:graphs] : []

      @@_cache[self.class.name] ||= SimpleCacheRequest.new(ocollection)
      @@cache_store ||= SimpleCacheStore.instance
    end

    # -------------------------------------------------------------------------
    #  Class methods - collection

    # Searches the collection; encodes any whitespace contained in the query
    # string. Returns SearchResult object where the results attribute contains
    # an array of Document objects.
    def self.orchio_search(collection, query_str)
      response = client.send_request( :get, {
        collection: collection,
        path: "?query=#{query_str.gsub(/\s/, '%20')}"
      })

      SearchResult.new(
        status:      orchio_status(response, 200),
        response:    sanitize(response),
        count:       response.body.count,
        total_count: response.body.total_count,
        results:     response.body.results.map { |result|
                       Document.new(
                         result['value'].merge(id: result['path']['key']),
                         Metadata.new(
                            collection: result['path']['collection'],
                            key:        result['path']['key'],
                            ref:        result['path']['ref'],
                            score:      result['score']
      ))})
    end

    # Lists the collection contents.  The results are based the options.
    # Returns Result object.
    def self.orchio_list(collection, path=nil)
      response = client.send_request :get, { collection: collection, path: path }
      Result.new(
        status:   orchio_status(response, 200),
        response: sanitize(response),
        count:    response.body.count,
        :next =>  response.body.next,
        results:  response.body.results.map { |result|
                    Document.new(
                      result['value'].merge(id: result['path']['key']),
                      Metadata.new(
                        collection: result['path']['collection'],
                        key:        result['path']['key'],
                        ref:        result['path']['ref'],
                      )
      )})
    end

    # Delete the specified collection.
    def self.orchio_delete(collection)
      response = client.send_request(
        :delete, { collection: collection, path: "?force=true" }
      )
      # SchemaCollection.delete(collection) if response.header.code == 204
      orchio_status response, 204
    end

    # Delete key from collection.
    def self.orchio_delete_key(collection, key)
      new(collection: collection, id: key).orchio_delete
    end

    # -------------------------------------------------------------------------
    #  Instance methods - collection/key

    # Fetches the data associated with this id from the collection.
    def orchio_get
      if cache.enabled? and response = cache_request.get(id)
        if response.header.status == :cache
          doc = response.body.document
        end
      else
        response = client.send_request :get, inst_args if response.nil?
        doc = Document.new(
                response.body.to_hash,
                Metadata.new(
                  :collection => ocollection,
                  :key => @id,
                  :ref => response.header.etag
              ))
      end
      Result.new(
        status:   orchio_status(response, 200),
        response: response,
        results:  [ doc ]
      )
    end

    # Updates the collection with the data associated with this instance.
    def orchio_put(jdoc)
      response = client.send_request :put, inst_args(json: jdoc)
      if cache.enabled?
        simple_cache.save(
          Document.new(
            response.body.to_hash,
            Metadata.new(
              :collection => ocollection,
              :key => @id,
              :ref => response.header.etag
        )))
      end
      set_ref_value response
      orchio_status response, 201
    end

    # Deletes the primary_key and data associated with this instance from
    # the collection.
    def orchio_delete
      response = client.send_request :delete, inst_args
      orchio_status response, 204
    end

    # Deletes the primary_key and <b>purges all of its immutable data</b>
    # from the collection.
    def orchio_purge
      response = client.send_request :delete, inst_args(path: "?purge=true")
      orchio_status response, 204
    end

    # -------------------------------------------------------------------------
    #  Instance methods - collection/key/ref

    # Gets the key/value pair by its 'ref' value.
    def orchio_get_by_ref(ref)
      response = client.send_request :get, inst_args(ref: ref)
      Result.new(
        status:   orchio_status(response, 200),
        response: response,
        results:  [ Document.new(
                      response.body.to_hash,
                      Metadata.new(
                        :collection => ocollection,
                        :key => @id,
                        :ref => response.header.etag
                  ))]
      )
    end

    # Updates the key/value if the send'ref' value matches the 'ref' value
    # for the latest version in the collection.
    def orchio_put_if_match(document, ref)
      response = client.send_request :put, inst_args(json: document, ref: ref)
      set_ref_value response
      orchio_status response, 201
    end

    # Updates the key/value if the key does not already exist in the collection.
    def orchio_put_if_none_match(document)
      orchio_put_if_match(document, '"*"')
    end

    # -------------------------------------------------------------------------
    # Instance methods - collection/key/events

    # Gets all events of specified type, within the timestamp parameters, where
    # timestamp = { :start => start, :end => end }.
    def orchio_get_events(event_type, timestamp={})
      # add_event_type event_type

      if cache.enabled? and response = cache_request.get_events(id, event_type)
        if response.header.status == :cache
          docs = response.body.documents
          count = docs.length
        end
      else
        response = client.send_request(
          :get, inst_args(event_type: event_type, timestamp: timestamp)
        )
        docs =  response.body.results.map { |result|
                  Document.new result['value'].merge(
                      key: @id,
                      etype: event_type,
                      timestamp: result['timestamp']
                    ),
                    Metadata.new(
                      collection: ocollection,
                      key: @id,
                      ref: funkify("#{event_type}#{result['timestamp']}"),
                      etype: event_type,
                    )
                }
        cache.save_event(id, event_type) if cache.enabled? and count == 0
      end
      Result.new(
        status:   orchio_status(response, 200),
        response: response,
        count:    response.body.count,
        results:  docs
      )
    end

    def orchio_put_event(event_type, timestamp=nil, document)
      # add_event_type event_type
      response = client.send_request(:put, inst_args(
        event_type: event_type, timestamp: timestamp, json: document
      ))
      orchio_status response, 204
    end

    # -------------------------------------------------------------------------
    # Instance methods - collection/key/graph

    # Gets the graph for the specified kind of relation.
    def orchio_get_graph(kind)
      # add_relation_kind kind
      if cache.enabled? and response = cache_request.get_graph(id, kind)
        if response.header.status == :cache
          docs = response.body.documents
          count = docs.length
        end
      else
        response = client.send_request :get, inst_args(kind: kind)
        docs =  response.body.results.map { |result|
                  Document.new(
                    result['value'].merge(id: result['path']['key']),
                    Metadata.new(
                      :collection => result['path']['collection'],
                      :key => result['path']['key'],
                      :ref => result['path']['ref'],
                      :kind => kind,
                      :from_collection => ocollection,
                      :from_key => @id,
                ))}
        cache.save_graph(id, kind) if cache.enabled? and count == 0
      end
      Result.new(
        status:   orchio_status(response, 200),
        response: response,
        count:    response.body.count,
        results:  docs
      )
    end

    # Add a graph/relation to the collection.
    # Store the to_key's 'ref' value if caching is enabled.
    def orchio_put_graph(kind, to_collection, to_key)
      # add_relation_kind kind

      if cache.enabled?
        ref = simple_cache.get_ref to_collection, to_key
        simple_cache.get_cc(ocollection).save_graph Metadata.new(
          { from_key: @id, kind: kind, ref: ref }
        )
      end

      response = client.send_request(
        :put,
        inst_args(kind: kind, to_collection: to_collection, to_key: to_key)
      )
      orchio_status response, 204
    end

    # Delete a graph/relation from the collection.
    def orchio_delete_graph(kind, to_collection, to_key)
      response = client.send_request(
        :delete,
        inst_args(
          kind:          kind,
          to_collection: to_collection,
          to_key:        to_key,
          path:          "?purge=true"
      ))
      orchio_status response, 204
    end

    # -------------------------------------------------------------------------
    #  Public instance methods JMC

    # Returns the collection name for the current instance.
    def orchestrate_collection_name
      ocollection
    end

    # Returns the <b>ref</b> value for the current instance.
    # The <b>ref</b> value is an immutable value assigned to each
    # version of primary_key data in an orchestrate.io collection.
    def orchestrate_ref_value
      __ref_value__
    end

    # Returns the primary_key for the current instance.
    def orchestrate_primary_key
      id
    end

    # Returns the client handle.
    def orchestrate_client
      client
    end

    # -------------------------------------------------------------------------
    private

      # Returns the collection name for this instance.
      #
      # This method is called during initializtion with the value
      # of <b>:define_collection_name</b> from the params hash.
      # If this value is nil or blank, it is expected that the collection
      # name can be derived from the class name as shown:
      #
      # - class: Film => 'films'
      # - class: FilmClassic => 'film_classics'
      #
      # Any collection names that do not follow this convention must be
      # specified by adding the <b>:define_collection_name</b> key to
      # the params hash in the model class definition.
      #
      #  class Film < Orchestrate::Application::Record
      #    def initialize(params={})
      #      params[:define_collection_name] = "Classic_Film_Collection"
      #      super(params)
      #   end
      #  end
      #
      def init_collection_name(collection_name)
        (collection_name.blank?) ? File.basename(self.class.name.tableize)
                                 : collection_name
      end

      # After a successful PUT request,
      # updates the current instance's <b>ref</b> value (also referred to
      # as the <b>etag</b>)
      # and calls #orchio_update_ref_table.
      def set_ref_value(response)
        unless response.header.code != 201 || response.header.etag.blank?
          @__ref_value__ = response.header.etag
          orchio_update_ref_table response.header.timestamp
        end
      end

      # Updates the <b>ref table</b> collection with key/value data consisting
      # of the current instance's <em><b>collection, key, timestamp</b> and
      # <b>ref</b> values </em>, using the ref value as the primary key.
      # When the ref table feature is enabled, the ref table is
      # updated after each sucessful <b>put_key</b> request.
      def orchio_update_ref_table(timestamp)
        return if ocollection == RefTable.get_collection_name

        if RefTable.enabled?
          primary_key = __ref_value__.gsub(/"/, '')
          doc = {
            xcollection: ocollection,
            xkey:        id,
            xref:        primary_key,
            timestamp:   timestamp
          }.to_json
          RefTable.new(:id => primary_key).orchio_put doc
        end
      end

      # :stopdoc:
      # JMC
      def orchio_status(response, expected_code)
        self.class.orchio_status response, expected_code
      end
      # :startdoc:

      # Returns the client handle for requests to the orchestrate.io api.
      def client
        @@client ||= Orchestrate::Application::Connect.client
      end

      # Returns the collection name associated with the current instance's class.
      def ocollection
        @@_collection[self.class.name].name
      end

      # Returns hash that merges additional arguments with the ever-present
      # collection and key args.
      def inst_args(args={})
        args.merge(collection: ocollection, key: id)
      end

      # def add_event_type(type)
      #   @event_types << type unless @event_types.include? type
      # end

      # def add_relation_kind(kind)
      #   @relation_kinds << kind unless @relation_kinds.include? kind
      # end

      # Returns a unique identifer for the specified event.
      def funkify(etype_and_timestamp)
        funky = etype_and_timestamp.reverse.concat("#{ocollection}#{id}")
        funkier = funky.split('').shuffle(random: funky.length).join.delete('_')
        funkiest = funkier.bytes.join.to_i % 0xffffffffff
      end

      # Returns handle to the SimpleCacheCollection instance for this class.
      def cache
        @@_cache[self.class.name]
      end

      # Calls #cache. Explain! Used for clarity?  JMC
      def cache_request
        cache
      end

      # Returns handle to the SimpleCacheStore singleton instance.
      def simple_cache
        @@cache_store
      end

    # -------------------------------------------------------------------------
    #  Private class methods

      # Calls #client instance method.
      def self.client
        new.orchestrate_client
      end

      # Removes result data from the response body for a successful GET request
      # This is done to avoid redundancy, since the result data is already
      # included in the Result object.
      def self.sanitize(response)
        if response.header.code.to_i == 200
          Response.new do |r|
            r.success = response.success?
            r.header = response.header
            r.body = ResponseBody.new nil
          end
        else
          response
        end
      end

      # :stopdoc:
      # JMC
      def self.orchio_status(response, expected_code)
        # puts "        orchio_status: '#{response.header.code}'"
        status = true
        if response.header.code.to_i != expected_code
          puts "        Error: #{response.body.code}: \"#{response.body.message}\""
          status = false
        end
        status
      end
      # :startdoc:

  end

end

