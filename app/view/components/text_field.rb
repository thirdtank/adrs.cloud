require_relative "base_component"

class TextField < Brut::BaseComponent
  attr_reader :label, :input
  def initialize(label:,input:)
    @label = label
    @input = input
  end
end
