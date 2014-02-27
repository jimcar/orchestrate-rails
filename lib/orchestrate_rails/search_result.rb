module Orchestrate::Rails

  #  Handle search results. See parent class Orchestrate::Application::SearchResult.
  #
  class SearchResult < Orchestrate::Application::SearchResult
    attr_writer :results
  end

end