class CheckboxComponent < AppComponent
  attr_reader :label, :checkbox, :input_name, :constraint_violations
  def initialize(form:,label:,input_name:)
    @label = label
    @input_name = input_name
    @constraint_violations = form[@input_name].validity_state
    @checkbox = Brut::FrontEnd::Components::Inputs::TextField.for_form_input(
      form:,
      input_name:,
    )
  end
end
