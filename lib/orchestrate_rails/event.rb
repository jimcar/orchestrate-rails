module Orchestrate::Rails

  require "active_model"

  #  Class to support *dynamically defined* orchestrate.io/event instances
  #
  class Event
    include ::ActiveModel::Conversion
    extend ::ActiveModel::Naming

    def initialize(event_record)
      event_record.each do |k,v|
        self.class.send(:attr_reader, k.to_orchio_rails_attr)
        instance_variable_set("@#{k.to_orchio_rails_attr}", v)
      end
    end

    def id
      @timestamp
    end
  end

end