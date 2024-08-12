class Components::Button < AppComponent
  attr_reader :size, :color, :label, :icon, :confirmation_message, :confirm_dialog, :type, :formaction, :disabled, :value

  def initialize(size: :normal,
                 color: "gray",
                 label:,
                 icon: false,
                 formaction: nil,
                 disabled: false,
                 confirm: nil,
                 value: false,
                 confirm_dialog: nil,
                 type: nil)
    @size                 = size
    @color                = color
    @label                = label
    @icon                 = icon
    @formaction           = formaction
    @disabled             = disabled
    @confirmation_message = confirm
    @confirm_dialog       = confirm_dialog
    @value                = value
    @type                 = type
  end
end
