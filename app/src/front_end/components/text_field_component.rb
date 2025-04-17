class TextFieldComponent < AppComponent
  attr_reader :label, :input_name, :input_component, :constraint_violations
  def initialize(label:,form:, input_name: nil, autofocus: false, placeholder: false)
    @input_id = nil
    @label = if label.kind_of?(Hash)
               if label[:id]
                 @input_id = label[:id]
                 nil
               else
                 raise ArgumentError,"Hash for a label must have an id: element: #{label.keys.map(&:to_s).join(", ")}"
               end
             else
               label
             end
    @input_name = input_name.kind_of?(Symbol) ? input_name.to_s : input_name
    @input_component = create_input_component(
      form:,
      autofocus:,
      placeholder:,
      input_id: @input_id
    )
    @constraint_violations = form.input(@input_name).validity_state
  end

  def container_tag = @label.nil? ? "div" : "label"
  def labeled_elsewhere? = @label.nil?
  def invalid? = @input_component.sanitized_attributes.key?("data-invalid")

private

  def create_input_component(form:,autofocus:,placeholder:,input_id:)
    input_html_attributes = {
      autofocus: autofocus,
      placeholder: placeholder,
      class: "text-field"
    }
    if input_id
      input_html_attributes.merge!(id: input_id)
    end
    Brut::FrontEnd::Components::Inputs::TextField.for_form_input(
      form: form,
      input_name: @input_name,
      html_attributes: input_html_attributes,
    )
  end
end
