class Components::Button < AppComponent
  attr_reader :size, :color, :label, :icon, :confirmation_message, :confirm_dialog
  def initialize(size: :normal, color: "gray", label:, icon: false, formaction: nil, disabled: false, confirm: nil, value: false, confirm_dialog: nil)
    @size       = size
    @color      = color
    @label      = label
    @icon       = icon
    @formaction = formaction
    @disabled   = disabled
    @confirmation_message = confirm
    @confirm_dialog = confirm_dialog
    @value = value
  end

  def formaction
    if @formaction
      "formaction='#{@formaction}'"
    else
      ""
    end
  end

  def disabled = @disabled ? "disabled" : ""
  def value = @value ? "value='#{@value}'" : ""
end
