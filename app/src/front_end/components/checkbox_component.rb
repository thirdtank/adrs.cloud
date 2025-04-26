class CheckboxComponent < AppComponent2
  def initialize(form:,label:,input_name:)
    @label = label.to_s
    @input_name = input_name.to_s
    @constraint_violations = form.input(@input_name).validity_state
    @checkbox = Brut::FrontEnd::Components::Inputs::TextField.for_form_input(
      form:,
      input_name:,
    )
  end

  def view_template
    label(class:"flex items-center gap-3") do
      render @checkbox
      div(class: "checkbox-label") do
        plain(@label)
      end
      div(class: "text-field-error-label") do
        brut_cv_messages(input_name: @input_name,class: "flex flex-wrap items-baseline") do
          @constraint_violations.each do |constraint|
            if !constraint.client_side?
              brut_cv(server_side: true, input_name: @input_name) do
                t("cv.be.#{constraint}", **constraint.context)
              end
            end
          end
        end
      end
    end
  end
end
