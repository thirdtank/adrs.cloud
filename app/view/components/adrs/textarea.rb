class Components::Adrs::Textarea < AppComponent
  attr_reader :prefix, :constraint_violations, :input_component, :label
  def initialize(form:, input_name:, label:, prefix:)
    @label = label
    @prefix = prefix
    @input_component = Brut::Components::Inputs::Textarea.for_form_input(
      form: form,
      input_name: input_name,
      html_attributes: { class: "textarea" }
    )
    @constraint_violations = form[input_name].validity_state
  end

  def invalid? = @input_component.sanitized_attributes.key?("data-invalid")

end

