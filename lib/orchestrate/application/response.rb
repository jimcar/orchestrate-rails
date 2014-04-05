module Orchestrate::Application

  # ---------------------------------------------------------------------------
  #  Inherits from Orchestrate::API::Response but
  #  Classes to handle orchestrate.io API responses - HTTParty
  #
  class Response < Orchestrate::API::Response
    attr_writer :success, :header, :body

    def initialize
      yield self if block_given?
    end
  end

  class ResponseBody < Orchestrate::API::ResponseBody
  end

  # ---------------------------------------------------------------------------

  # class Response
  #   attr_accessor :success, :header, :body

  #   def initialize
  #     yield self if block_given?
  #   end

  #   def success?
  #     @success == true
  #   end
  # end

  # class ResponseBody
  #   attr_reader :content, :to_hash, :results, :count, :total_count, :next

  #   def result_keys
  #   end
  # end

end
