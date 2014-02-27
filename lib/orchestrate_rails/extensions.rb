module Orchestrate::Rails

  # ---------------------------------------------------------------------------
  #  Add String and Symbol instance methods for easy conversion of
  #  orchestrate.io property names to rails-style model attribute names.

  # Convert property name to attribute name.
  class ::String
    def to_orchio_rails_attr
      underscore.downcase
    end
  end

  # Convert property name to attribute name. Calls ::String#to_orchio_rails_attr.
  class ::Symbol
    def to_orchio_rails_attr
      to_s.to_orchio_rails_attr
    end
  end

end
