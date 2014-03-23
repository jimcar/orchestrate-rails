module Orchestrate::Application

  class RefTable < Orchestrate::Application::Record

    @@is_enabled = false
    @@collection_name = 'orchio_ref_table'

    def initialize(params={})
      return unless @@is_enabled == true
      params[:define_collection_name] = @@collection_name
      super params
    end

    def self.enable(name = nil)
      puts "ENABLE REF TABLE"
      @@is_enabled = true
      @@collection_name = name unless name.blank?
      Orchestrate::Application::Schema.instance.define_collection(
        :name       => @@collection_name,
        :properties => [ :xcollection, :xkey, :timestamp, :xref]
      )
    end

    def self.enabled?
      @@is_enabled == true
    end

    def self.get_collection_name
      @@collection_name
    end

  end

end

