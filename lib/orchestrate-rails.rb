module Orchestrate

=begin rdoc

  ==== orchestrate-rails

  Ruby gem <tt>orchestrate-rails</tt> provides an ActiveRecord-style interface
  to map rails models to Orchestrate.io Databases-as-a-Service.

  The rails model interface to orchestrate.io collections
  is defined in the <b> Model</b> class.

  ==== {User Guide}[Rails/UserGuide.html]

  ==== {Try out the Tutorial!}[Rails/Tutorial.html]
=end

  module Rails

    extend ActiveSupport::Concern

    # include the 'hidden gem'
    require "orchestrate-application"

    require "orchestrate_rails/document"
    require "orchestrate_rails/schema"
    require "orchestrate_rails/model"
    require "orchestrate_rails/event"
    require "orchestrate_rails/search_result"
    require "orchestrate_rails/extensions"

  end
end

