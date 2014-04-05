module Orchestrate::Rails

  require "active_model"

  # Class to define rails models for Orchestrate.io DataBases-as-a-Service.
  # The library provides a base class that, when subclassed to define a model,
  # sets up a mapping between the model and an Orchestrate.io collection.
  #
  class Model < Orchestrate::Application::Record
    include ::ActiveModel::Validations
    include ::ActiveModel::Serialization
    include ::ActiveModel::Serializers
    include ::ActiveModel::Serializers::JSON
    include ::ActiveModel::Conversion
    extend ::ActiveModel::Naming

    validates_presence_of :id

    # Creates instance variable for each model attribute defined by the schema.
    # Initializes any attribute values that are passed in via the params hash
    # and then initializes the @attributes instance variable.
    #
    # Any key/value pair in params whose key is not an attribute
    # (i.e. :id or :define_collection_name) is passed on to the superclass.
    #
    def initialize(params={})super(params)
      # Define accessor and query methods for each attribute.
      attrs.each do |attribute|
        self.class.send :attr_accessor, attribute
        define_attr_query attribute
      end

      # Set instance variables and initialize @attributes with any
      # attribute values that were passed in the params hash.
      @attributes = {}
      params.each do |k,v|
        if attrs.include? k.to_s
          send("#{k}=", v)
          @attributes[k] = v
        end
      end
    end

    # Called by ActiveModel::Validation
    def read_attribute_for_validation(attribute)
      instance_variable_get("@#{attribute}")
    end

    # Called by ActiveModel::Serialization
    def read_attribute_for_serialization(attribute)
      instance_variable_get("@#{attribute}")
    end

    # -------------------------------------------------------------------------
    # Instance methods

    # Returns array of model attribute names.
    def attrs
      self.class.attrs
    end

    # Returns hash of key/value pairs.
    def attributes
      @attributes = Hash[attrs.map { |a| [a.to_sym, send("#{a}")] }]
    end

    # :stopdoc:
    def properties
      self.class.properties
    end
    # :startdoc:

    # -------------------------------------------------------------------------
    #  Public convenience methods - JMC

    # Returns the collection name for the current instance.
    def orchestrate_collection_name
      ocollection
    end

    # Returns the <tt>ref</tt> value for the current instance.
    # The <tt>ref</tt> value is an immutable value assigned to each
    # version of primary_key data in an orchestrate.io collection.
    def orchestrate_ref_value
      __ref_value__
    end

    # -------------------------------------------------------------------------
    #  Instance methods to mimic some basic ActiveRecord-style functionality

    #
    def retval(status, obj=nil)
      if status == true
        (obj.blank?) ? self : obj
      else
        status
      end
    end
    private :retval

    # Returns the key/value data for the current instance.
    def get
      res = orchio_get
      (res.success?) ? res.result.update_rails(self) : false
    end

    # Returns the key/value data for the current instance,
    # found by <tt>ref</tt> value.
    def get_by_ref(ref)
      res = orchio_get_by_ref ref
      (res.success?) ? res.result.update_rails(self) : false
    end

    # Updates the collection with current instance data,
    # if the primary_key (id) does not exist in the collection.
    #
    # Returns the instance upon success; false upon failure.
    def save_if_none_match
      status = orchio_put_if_none_match(to_json_direct) if valid?
      retval status
    end


    # Updates the collection with current instance data,
    # if the <tt>ref</tt> value matches the <tt>ref</tt> value associated
    # with the same primary_key in the collection.
    #
    # Returns the instance upon success; false upon failure.
    def save_if_match
      status = orchio_put_if_match(to_json_direct, __ref_value__) if valid?
      retval status
    end

    # Calls #save_if_match.
    def save
      save_if_match
    end

    # Updates the collection with current instance data.
    #
    # Returns the instance upon success; false upon failure.
    def save!
      status = orchio_put(to_json_direct) if valid?
      retval status
    end

    # Updates the attribute and calls #save_if_match.
    def update_attribute(key, value)
      instance_variable_set "@#{key}", value
      save_if_match
    end

    # Updates the attributes and calls #save_if_match.
    def update_attributes(key_value_pairs)
      key_value_pairs.each { |k,v| instance_variable_set "@#{k}", v }
      save_if_match
    end

    # :stopdoc:
    # Updates the attribute and calls #save!. Use with caution!!!
    def update_attribute!(key, value)
      instance_variable_set "@#{key}", value
      save!
    end

    # Updates the attributes and calls #save!. Use with caution!!!
    def update_attributes!(key_value_pairs)
      key_value_pairs.each { |k,v| instance_variable_set "@#{k}", v }
      save!
    end
    # :startdoc:

    # Deletes the current primary_key from the collection. Calls #orchio_delete
    #
    # Returns boolean status.
    def destroy
      orchio_delete
    end

    # Deletes the current primary_key and
    # <b>purges all of its immutable data</b> from the collection.
    #
    # Returns boolean status.
    def destroy!
      orchio_purge
    end

    # -------------------------------------------------------------------------
    #  Instance methods for Orchestrate.io events

    # :stopdoc:
    def all_events
      event_types.map { |etype| events(etype) }
    end
    # :startdoc:

    # Returns array of event instances specified by event_type and timestamp range,
    #
    # where the timestamp range is specified as { :start => start, :end => end }
    def events(event_type, timestamp={})
      res = orchio_get_events(event_type, timestamp)
      (res.success?) ? res.results.map { |odoc| odoc.to_event } : false
    end

    # Updates the collection with the specified event instance.
    #
    # Returns the event instance upon success; false upon failure.
    def save_event(event_type, timestamp=nil, event)
      retval orchio_put_event(event_type, timestamp, event.to_json), event
    end

    # Creates event instance; calls #save_event to update the collection.
    #
    # Returns the event instance upon success; false upon failure.
    def create_event(event_type, timestamp=nil, event_rec)
      save_event event_type, timestamp, Event.new(event_rec)
    end

    # -------------------------------------------------------------------------
    #  Instance methods for Orchestrate.io graphs

    # :stopdoc:
    def all_graphs
      graphs.map { |kind| graph kind }
    end
    # :startdoc:

    # Returns array of instances associated with the specified kind of relation.
    def graph(kind)
      res = orchio_get_graph(kind)
      (res.success?) ? res.results.map { |odoc| odoc.to_rails } : false
    end

    # Updates the collection with the specified graph relation.
    #
    # Returns boolean status.
    def save_graph(kind, to_collection, to_key)
      retval orchio_put_graph(kind, to_collection, to_key)
    end

    # Removes the specified relation from the graph.
    #
    # Returns boolean status.
    def delete_graph(kind, to_collection, to_key)
      retval orchio_delete_graph kind, to_collection, to_key
    end

    # -------------------------------------------------------------------------
    #  Helper methods

    # Defines query method to test whether the attribute value is present.
    def define_attr_query(attribute)
      self.class.send :define_method, "#{attribute}?" do
        !instance_variable_get("@#{attribute}").blank?
      end
    end
    private :define_attr_query

    # Generates json for the attribute key/value pairs, replacing attribute
    # names used by the model with the property names used in the collection.
    def to_json_direct
      Hash[attrs.map { |a| [qmap[a], instance_variable_get("@#{a}")] }].to_json
    end
    private :to_json_direct

    # :stopdoc:
    def to_properties(json_str)
      keys = json_str.scan(/\"(\w+)\":/).map { |result| result.first }
      keys.each { |key| json_str.gsub!(/\"#{key}\":/, "\"#{qmap[key]}\":") }
      json_str
    end

    def qmap
      self.class.qmap
    end
    # :startdoc:

    # -------------------------------------------------------------------------
    #  Class methods

    # Returns the table that maps attribute names to property names.
    #
    # This mapping also works when the input is a property name.
    def self.qmap
      schema.qmap ocollection
    end

    # Returns array of model attribute names.
    def self.attrs
      schema.attrs ocollection
    end

    def self.attributes
      new.attributes
    end

    # Returns array of property names.
    #
    # Property names are the original key names in json documents stored
    # in orchestrate collections - before they are converted to the snake_case
    # style used for model attribute names. Attribute names are mapped to
    # property names using ::qmap. Property names can be mapped to
    # attribute names with ::Symbol#to_orchio_rails_attr or
    # ::String#to_orchio_rails_attr.
    #
    def self.properties
      schema.properties(ocollection).select { |prop| prop !~ /id/i }
    end

    # -------------------------------------------------------------------------
    #  Class methods to mimic some basic ActiveRecord-style functionality

    # Creates a new instance; updates the collection if the primary_key
    # is not already present in the collection.
    #
    # Returns the instance upon success; false upon failure.
    def self.create(key_value_pairs)
      new(key_value_pairs).save_if_none_match
    end

    # Creates a new instance; updates the collection.
    #
    # Returns the instance upon success; false upon failure.
    def self.create!(key_value_pairs)
      new(key_value_pairs).save!
    end

    # Deletes the specified instance from the collection.
    #
    # Returns boolean status.
    def self.destroy(id)
      new(:id => id).destroy
    end

    # Deletes the specified instance and
    # <b>purges all of its immutable data</b> from the collection.
    #
    # Returns boolean status.
    def self.destroy!(id)
      new(:id => id).destroy!
    end

    # Deletes the entire collection.
    #
    # Returns boolean status.
    def self.destroy_all
      orchio_delete ocollection
    end

    # Returns ordered array of all instances in the collection.
    def self.all
      res = list
      (res.success?) ? res.results : false
    end

    # Returns the first (ordered) instance in the collection.
    def self.first
      res = list(1)
      (res.success?) ? res.results.first : false
    end

    # Returns the last (ordered) instance in the collection.
    def self.last
      all.last
    end

    # Returns the first (random) instance in the collection.
    def self.take
      res = search('*', 1)
      (res.success?) ? res.results.first : false
    end

    # Returns boolean to indicate whether the specified primary_key exists
    # in the collection.
    def self.exists?(id)
      find(id) ? true : false
    end

    # Find by the primary_key (id). Can be a specific id, or an array of ids.
    #
    # Returns instance, or array of instances, accordingly.
    def self.find(arg)
      if arg.is_a? Integer or arg.is_a? String
        new(:id => arg).get
      elsif arg.is_a? Array
        arg.map { |id| new(:id => id).get }
      end
    end

    # Returns all instances that match the specified criteria.
    def self.where(key_value_pairs)
      search_results(key_value_pairs.map{ |k,v| "#{k}:#{v}" }.join(' AND '))
    end

    # Returns the first instance that matches the specified criteria.
    def self.find_by(key_value_pairs)
      where(key_value_pairs).first
    end

    # Calls ::find_by for properly constructed 'find_by_attribute(s)' calls.
    #
    # Example: <tt>User.find_by_name_and_address(name, address)</tt>
    # is executed as:
    #
    # <tt>User.find_by(:name => name, :address => address)</tt>
    def self.find_by_method(myattrs, *args, &block)
      attrs_with_args = [myattrs.split('_and_'), args].transpose
      attrs_with_args.each { |awa| return unless attrs.include? awa.first }
      find_by Hash[attrs_with_args]
    end

    # Calls ::find_by_method for 'find_by_attribute(s)'.
    def self.method_missing(name, *args, &block)
      if name.to_s =~ /^find_by_(.+)$/
        find_by_method($1, *args, &block) || super
      else
        super
      end
    end

    # Handles find_by_attribute methods.
    def self.respond_to?(name)
      (attributes.include?(name) and name.to_s =~ /^find_by_.*$/) or super
    end

    # -----------------------------------------------------------------------

    # Returns array of model instances that match the query string.
    def self.search_results(query_str)
      res = search(query_str)
      (res.success?) ? res.results : false
    end

    # Returns SearchResult. Orchestrate.io search implements Lucene Query
    # Parser Syntax.
    def self.search(query_str, limit=:all, offset=0)
      query_str = orchio_query_str(query_str) unless query_str == '*'
      if limit == :all
        total_count = offset + 1
        max = 100
        qdocs = []
        while offset < total_count
          qresult = orchio_search(
            ocollection, "#{query_str}&limit=#{max}&offset=#{offset}"
          )
          offset += qresult.count
          total_count = qresult.total_count
          qdocs += qresult.results
        end
        qresult = SearchResult.new(
          results:     qdocs,
          count:       offset,
          total_count: total_count,
          status:      qresult.status,
          response:    qresult.response
        )
      else
        qresult = orchio_search(
          ocollection, "#{query_str}&limit=#{limit}&offset=#{offset}"
        )
      end
      qresult.results.map! { |odoc| odoc.to_rails }
      qresult
    end

    # Returns Orchestrate::Application::Result.
    #
    # The start index may be optionally specified by using either start_key
    # (inclusive) or after_key (exclusive). The default is the first primary
    # key in the collection.
    def self.list(limit=:all, start_key=nil, after_key=nil)
      if limit == :all
        total_count = 0
        max = 100
        result = orchio_list ocollection, "?limit=#{max}"
        count = result.count
        docs = result.results
        while result.next
          result = orchio_list ocollection, "?#{result.next.split('?').last}"
          docs += result.results
          count += result.count
        end
        result = Orchestrate::Application::Result.new(
          results:  docs,
          count:    count,
          status:   result.status,
          response: result.response
        )
      else
        option_str = "?limit=#{limit}"
        option_str += "&startKey=#{start_key}" if start_key and after_key.nil?
        option_str += "&afterKey=#{after_key}" if after_key and start_key.nil?
        result = orchio_list ocollection, option_str
      end
      result.results.map! { |odoc| odoc.to_rails }
      result
    end

    # :stopdoc:
    def self.ocollection
      schema.get_collection_from_class(self.name).name
    end
    # :startdoc:

    # -----------------------------------------------------------------------

    private

      # Returns handle to the Schema singleton instance.
      def self.schema
        @@schema ||= Schema.instance
      end

      # Returns an orchestrate-ready query string for the search request.
      # The attribute names used by the model are replaced with the property
      # names used in the collection.
      def self.orchio_query_str(query_str)
        keys = query_str.scan(/^(\w+):/).map { |r| r.first } +
               query_str.scan(/\s(\w+):/).map { |r| r.first }
        keys.each { |k| query_str.gsub!(/#{k}:/, "#{qmap[k]}:") if qmap[k] }
        query_str
      end

  end

end
