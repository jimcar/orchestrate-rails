module Orchestrate::Application

  # ---------------------------------------------------------------------------
  #  Class to handle Orchestrate.io API responses
  #
  class SimpleCacheResponse
    attr_accessor :header, :body

    def initialize(header, body)
      @header, @body = Header.new(header), Body.new(body)
    end

    def success?
      true
    end

    class Header
      attr_reader :locations, :code, :status, :etag, :content

      def initialize(header)
        @locations = header[:locations]
        @code, @status = header[:code], header[:status]
        @etag = header[:etag]
        @content = {}
      end

      def location
        locations.first
      end
    end

    class Body
      attr_reader :documents, :count, :content

      def initialize(body)
        @documents = body
        @count = documents.length
        @content = nil
      end

      def document
        documents.first
      end
    end

  end

end