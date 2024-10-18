class Brut::FrontEnd::Components::Inputs::Select < Brut::FrontEnd::Components::Input
  def self.for_form_input(form:,
                          input_name:,
                          options:,
                          selected_value:,
                          value_attribute:,
                          option_text_attribute:,
                          html_attributes: {})
    default_html_attributes = {}
    input = form[input_name]
    default_html_attributes["name"]     = input.name
    default_html_attributes["required"] = input.required
    if !form.new? && !input.valid?
      default_html_attributes["data-invalid"] = true
      input.validity_state.each do |constraint,violated|
        if violated
          default_html_attributes["data-#{constraint}"] = true
        end
      end
    end
    Brut::FrontEnd::Components::Inputs::Select.new(
      options:,
      selected_value:,
      value_attribute:,
      option_text_attribute:,
      html_attributes: default_html_attributes.merge(html_attributes)
    )
  end
  def initialize(options:,
                 selected_value:,
                 value_attribute:,
                 option_text_attribute:,
                 html_attributes:)
    @options               = options
    @selected_value        = selected_value
    @value_attribute       = value_attribute
    @option_text_attribute = option_text_attribute
    @sanitized_attributes  = html_attributes.map { |key,value|
        [
          key.to_s.gsub(/[\s\"\'>\/=]/,"-"),
          value
        ]
    }.select { |key,value|
      !value.nil?
    }.to_h
  end

  def render
    html_tag(:select,**@sanitized_attributes) {
      @options.map { |option|
        value = option.send(@value_attribute)
        option_attributes = { value: value }
        if value == @selected_value
          option_attributes[:selected] = true
        end
        html_tag(:option,**option_attributes) {
          option.send(@option_text_attribute)
        }
      }.join("\n")
    }
  end
end
