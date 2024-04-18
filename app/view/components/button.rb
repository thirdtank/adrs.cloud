require_relative "base_component"

class Button < Brut::BaseComponent
  attr_reader :size, :color, :label
  def initialize(size: :normal, color: gray, label:)
    @size  = size
    @color = color
    @label = label
  end
end
