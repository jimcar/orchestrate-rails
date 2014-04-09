module Orchestrate::Application

  # Class for creating the connection between the application and the
  # orchestrate.io api.
  #
  class Connect

    # default config file: "<app-root-dir>/orch_config.json"
    # @@config_file = "orch_config.json"

    # def self.config(config_file)
    #   @@config_file = config_file
    # end

    def self.client
      @@client ||= connect
    end

    private
      def self.connect
        Orchestrate::API::Wrapper.new
        # Orchestrate::API::Wrapper.new @@config_file
      end
  end

end