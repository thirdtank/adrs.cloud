class ButtonComponent < AppComponent
  attr_reader :size,
              :color,
              :label,
              :aria_label,
              :icon,
              :confirmation_message,
              :confirm_dialog,
              :type,
              :formaction,
              :disabled,
              :value,
              :title

  def initialize(size: :normal,
                 color: "gray",
                 label:,
                 aria_label: nil,
                 icon: false,
                 formaction: nil,
                 title: nil,
                 disabled: false,
                 confirm: nil,
                 value: false,
                 confirm_dialog: nil,
                 variant: :normal,
                 width: :minimum,
                 type: nil)
    @size                 =   size
    @color                =   color
    @label                =   label
    @aria_label           =   aria_label
    @icon                 =   icon
    @formaction           =   formaction
    @disabled             = !!disabled
    @confirmation_message =   confirm
    @confirm_dialog       =   confirm_dialog
    @value                =   value
    @type                 =   type
    @variant              =   variant
    @width                =   width

    disabled_message = disabled.kind_of?(String) ? disabled : nil
    @title                =   if @disabled
                                disabled_message
                              elsif title
                                title
                              elsif aria_label
                                aria_label
                              else
                                label
                              end
  end


  def variant_class
    case @variant
    when :normal then ""
    when :left   then "button--variant--left"
    when :right  then "button--variant--right"
    when :middle then "button--variant--middle"
    when :search then "button--variant--search"
    else
      raise ArgumentError.new("variant '#{@variant}' is unknown. Must be :normal, :left, :middle, :right")
    end
  end

  def width_class
    if @width == :full
      "w-100"
    else
      ""
    end
  end
end
