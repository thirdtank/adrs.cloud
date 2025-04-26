class Adrs::TextareaComponent < AppComponent2
  def initialize(form:, input_name:, label:, context:)
    @label = label.to_s
    @context = context.to_s
    @input_name = input_name
    @form = form
    @input_component = Brut::FrontEnd::Components::Inputs::Textarea.for_form_input(
      form: @form,
      input_name: @input_name,
      html_attributes: { class: "textarea", rows: 5, }
    )
  end

  def invalid? = @input_component.invalid?

  def view_template
    label(class: "flex flex-column gap-1 w-100") do
      div(class: "textarea-container", data_invalid: invalid?) do
        div(class: "inner-label") { @label }
        render @input_component
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
      div(class: "text-field-label") do
        span(class: "f-1") { @context }
      end
    end
  end

end

