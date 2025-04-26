class CheckboxComponent < AppComponent
  def initialize(form:,label:,input_name:)
    @form = form
    @label = label.to_s
    @input_name = input_name.to_s
    @checkbox = Brut::FrontEnd::Components::Inputs::TextField.for_form_input(
      form: @form,
      input_name: @input_name,
    )
  end

  def view_template
    label(class:"flex items-center gap-3") do
      render @checkbox
      div(class: "checkbox-label") do
        plain(@label)
      end
      div(class: "text-field-error-label") do
        render(
          Brut::FrontEnd::Components::ConstraintViolations.new(
            form: @form,
            input_name: @input_name,
            class: "flex flex-wrap items-baseline"
          )
        )
      end
    end
  end
end
