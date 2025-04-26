class ButtonComponent < AppComponent
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
    @label                =   label&.to_s
    @aria_label           =   aria_label&.to_s
    @icon                 =   icon
    @formaction           =   formaction&.to_str
    @disabled             = !!disabled
    @confirmation_message =   confirm
    @confirm_dialog       =   confirm_dialog
    @value                =   value
    @type                 =   type
    @variant              =   variant
    @width                =   width

    @title                =   if @disabled
                                if disabled == true
                                  label&.to_s
                                else
                                  disabled.to_s
                                end
                              elsif title
                                title&.to_s
                              elsif aria_label
                                aria_label&.to_s
                              else
                                label&.to_s
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

  def view_template
    if @confirmation_message
      brut_confirm_submit(message: @confirmation_message.to_s, show_warnings: @label, class: width_class, dialog: @confirm_dialog) do
        button_only
      end
    else
      button_only
    end
  end
  def button_only
    attributes = {
      title: @title,
      class: "flex items-center justify-center #{width_class} gap-2 button button--size--#{ @size } button--color--#{ @color } #{ variant_class }",
      aria_label: @aria_label || @label,
      disabled: @disabled,
      type: @type,
      formaction: @formaction,
      value: @value,
    }
    button(**attributes) do
      if @icon
        span(aria_hidden: true) do
          inline_svg(@icon)
        end
      end
      plain(@label)
    end
  end
end
