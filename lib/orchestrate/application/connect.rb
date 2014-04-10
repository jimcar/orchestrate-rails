module Orchestrate::Application

  # Class for creating the connection between the application and the
  # Orchestrate API.
  #
  class Connect

    def self.client
      @@client ||= connect
    end

    private

      def self.connect
        Orchestrate::Client.new
      end

  end

end