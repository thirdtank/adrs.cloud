module Sequel
  module Plugins
    module FindBang
      module ClassMethods
        def find!(...)
          self.first!(...)
        end
      end
    end
  end
end
