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

  # include the 'hidden gem'
  require "orchestrate-application"

  module Rails

    require 'active_support/core_ext'
    extend ActiveSupport::Concern

    require "orchestrate/rails/document"
    require "orchestrate/rails/schema"
    require "orchestrate/rails/model"
    require "orchestrate/rails/event"
    require "orchestrate/rails/search_result"
    require "orchestrate/rails/extensions"

  end
end

