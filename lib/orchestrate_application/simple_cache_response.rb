module Orchestrate::Application

  # ---------------------------------------------------------------------------
  #  Class to handle Orchestrate.io API responses
  # 
  class SimpleCacheResponse
    attr_accessor :header, :body

    def initialize(header, body)
      @header, @body = Header.new(header), Body.new(body)
    end

    class Header
      attr_reader :locations, :code, :status, :etag

      def initialize(header)
        @locations = header[:locations]
        @code, @status = header[:code], header[:status]
        @etag = header[:etag]
      end

      def location
        locations.first
      end
    end

    class Body
      attr_reader :documents
      
      def initialize(body)
        @documents = body
      end

      def document
        documents.first
      end
    end

  end

end