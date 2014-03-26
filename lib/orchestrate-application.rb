module Orchestrate

=begin rdoc

  ==== orchestrate-application

  This <em>hidden gem <b>orchestrate-application</b></em> is embedded within
  the <em>orchestrate-rails</em> gem to provide a basic interface and
  accompanying set of services for accessing orchestrate.io collections from
  <b><em>any type of application written in ruby</em></b>.
  The application layer features services for connecting
  to the api, sending requests and handling responses, as well as additional
  services for schema definition and cache management.

  The application-layer interface to orchestrate.io collections is defined
  in the <b>Record[Application/Record.html]</b> class.

  ==== {Usage example}[Application/Example.html]
=end

  module Application

    require "orchestrate_application/schema_collection"
    require "orchestrate_application/schema"
    require "orchestrate_application/connect"
    require "orchestrate_application/record"
    require "orchestrate_application/document"
    require "orchestrate_application/ref_table"
    require "orchestrate_application/result"
    require "orchestrate_application/response"
    require "orchestrate_application/simple_cache_store"
    require "orchestrate_application/simple_cache_request"
    require "orchestrate_application/simple_cache_response"

  end
end
