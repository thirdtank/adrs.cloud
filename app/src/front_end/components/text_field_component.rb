class TextFieldComponent < AppComponent2
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
               label.to_s
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

  def labeled_elsewhere? = @label.nil?
  def invalid? = @input_component.sanitized_attributes.key?("data-invalid")

  def view_template
    if @label.nil?
      div(class: "flex flex-coumn gap-1 w-100") do
        internal_view_template
      end
    else
      label(class: "flex flex-coumn gap-1 w-100") do
        internal_view_template
      end
    end
  end

  def internal_view_template
    input_component
    div(class: "text-field-error-label") do
      brut_cv_messages(show_warnings: true, input_name: @input_name, class: "flex flex-wrap items-baseline") do
        @constraint_violations.each do |constraint|
          if !constraint.client_side?
            brut_cv(server_side: true, input_name: @input_name, show_warnings: true) do
              t("cv.be.#{constraint}", **constraint.context).capitalize.to_s
            end
          end
        end
      end
    end
    if !labeled_elsewhere?
      div(class: "text-field-label") do
        plain(@label)
      end
    end
  end

private

  def input_component
    raw(safe(@input_component.render.to_s))
  end

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
