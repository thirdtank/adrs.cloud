class Adrs::TextareaComponent < AppComponent
  attr_reader :input_name, :constraint_violations, :input_component, :label, :context
  def initialize(form:, input_name:, label:, context:)
    @label = label
    @context = context
    @input_name = input_name
    @input_component = Brut::FrontEnd::Components::Inputs::Textarea.for_form_input(
      form: form,
      input_name: @input_name,
      html_attributes: { class: "textarea", rows: 5, }
    )
    @constraint_violations = form[@input_name].validity_state
  end

  def invalid? = @input_component.sanitized_attributes.key?("data-invalid")

end

