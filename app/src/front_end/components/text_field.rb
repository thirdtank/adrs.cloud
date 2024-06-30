class Components::TextField < AppComponent
  attr_reader :label, :input_component, :constraint_violations
  def initialize(label:,form:, input_name: nil, autofocus: false, placeholder: false)
    @label = label
    @input_component = Brut::FrontEnd::Components::Inputs::TextField.for_form_input(
      form: form,
      input_name: input_name,
      html_attributes: { autofocus: autofocus, placeholder: placeholder, class: "text-field" }
    )
    @constraint_violations = form[input_name].validity_state
  end
end
