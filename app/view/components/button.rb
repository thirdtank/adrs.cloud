class Components::Button < AppComponent
  attr_reader :size, :color, :label, :icon
  def initialize(size: :normal, color: "gray", label:, icon: false, formaction: nil, disabled: false)
    @size       = size
    @color      = color
    @label      = label
    @icon       = icon
    @formaction = formaction
    @disabled   = disabled
  end

  def formaction
    if @formaction
      "formaction='#{@formaction}'"
    else
      ""
    end
  end

  def disabled = @disabled ? "disabled" : ""
end
