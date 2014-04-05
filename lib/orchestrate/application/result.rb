module Orchestrate::Application

  # Packages the result data from GET requests.
  # Orchestrate.io records are returned as Document objects.
  #
  class Result
    # Array of Document objects.
    attr_reader :results

    # Count of documents in #results. Set for list, search, events, and graph.
    attr_reader :count

    # Set for list results.
    attr_reader :next

    # Upon success: the result data is extracted from the response body,
    # but the response body itself is not inluded as part of the result.
    #
    # Upon failure: the original response body, Orchestrate::API::ResponseBody
    # is left intact and included to provide access to the error details.
    attr_reader :response

    # Boolean: return status of the api call.
    attr_reader :status

    # Initialize instance variables, based on type of results.
    # - results                     (key/value)
    # - results, count              (events, graph)
    # - results, count, next        (list)
    # - results, count, total_count (search)
    def initialize(results)
      results.each { |k,v| instance_variable_set "@#{k}", v }
    end

    def result
    	results.first
    end

    def result_keys
      results.map { |result| result.metadata.key }
    end

    def success?
      status == true
    end
  end

  # Container class for Orchestrate.io search results.
  # See parent class Result for more details.
  #
  class SearchResult < Result
    # Total count of matched records.
    attr_reader :total_count
  end

end
