module Orchestrate::Rails

  # Extensions #update_rails, #to_rails, #to_event are defined in the
  # Orchestrate::Rails module and are accessible within that namespace.
  #
  class Orchestrate::Application::Document

    # Updates the key/value pairs for the model instance with key/value data
    # from the document.
    # Defined by Orchestrate::Rails.
    def update_rails(instance)
      key_value_pairs.each { |k,v|
        instance.instance_variable_set "@#{k.to_orchio_rails_attr}", v
      }
      instance.instance_variable_set "@__ref_value__", metadata.ref # JMC
      instance
    end

    # Creates a new model instance, and calls #update_rails.
    # Defined by Orchestrate::Rails.
    def to_rails
      update_rails Object.const_get(classname).new
    end

    # Creates a new event instance from the document's key/value data.
    # Defined by Orchestrate::Rails.
    def to_event
      Object.const_get('Orchestrate::Rails::Event').new key_value_pairs
    end

    private
      def classname
        Orchestrate::Rails::Schema.instance.fullclassname metadata.collection
        # Orchestrate::Rails::Schema.instance.classname(metadata.collection) JMC
      end
  end

end