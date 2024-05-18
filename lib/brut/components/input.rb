require "rexml"
module Brut::Components

  module Inputs
    autoload(:TextField,"brut/components/inputs/text_field")
    autoload(:Textarea,"brut/components/inputs/textarea")
  end

  class Input < Brut::Component
  end
end
