class Adrs::TextareaComponent < AppComponent2
  def initialize(form:, input_name:, label:, context:)
    @label = label.to_s
    @context = context.to_s
    @input_name = input_name
    @input_component = Brut::FrontEnd::Components::Inputs::Textarea.for_form_input(
      form: form,
      input_name: @input_name,
      html_attributes: { class: "textarea", rows: 5, }
    )
    @constraint_violations = form.input(@input_name).validity_state
  end

  def invalid? = @input_component.sanitized_attributes.key?("data-invalid")

  def view_template
    label(class: "flex flex-column gap-1 w-100") do
      div(class: "textarea-container", data_invalid: invalid?) do
        div(class: "inner-label") { @label }
        raw(safe(@input_component.render.to_s))
      end
      div(class: "text-field-error-label") do
        brut_cv_messages(
          input_name: @input_name,
          class: "flex flex-wrap items-baseline"
        ) do
        end
        @constraint_violations.each do |constraint|
          if !constraint.client_side?
            brut_cv(server_side: true, input_name: @input_name) do
              t("cv.be.#{constraint}", **constraint.context)
            end
          end
        end
      end
      div(class: "text-field-label") do
        span(class: "f-1") { @context }
      end
    end
  end

end

