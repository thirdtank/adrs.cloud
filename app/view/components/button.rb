class Components::Button < AppComponent
  attr_reader :size, :color, :label, :icon
  def initialize(size: :normal, color: "gray", label:, icon: false)
    @size  = size
    @color = color
    @label = label
    @icon  = icon
  end
end
