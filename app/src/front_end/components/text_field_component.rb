class TextFieldComponent < AppComponent
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
    @form = form
    @input_name = input_name.kind_of?(Symbol) ? input_name.to_s : input_name
    @input_component = create_input_component(
      form: @form,
      autofocus:,
      placeholder:,
      input_id: @input_id
    )
  end

  def labeled_elsewhere? = @label.nil?
  def invalid? = @input_component.invalid?

  def view_template
    if @label.nil?
      div(class: "flex flex-column gap-1 w-100") do
        internal_view_template
      end
    else
      label(class: "flex flex-column gap-1 w-100") do
        internal_view_template
      end
    end
  end

  def internal_view_template
    input_component
    div(class: "text-field-error-label") do
      render(
        Brut::FrontEnd::Components::ConstraintViolations.new(
          form: @form,
          input_name: @input_name,
          class: "flex flex-wrap items-baseline"
        )
      )
    end
    if !labeled_elsewhere?
      div(class: "text-field-label") do
        plain(@label)
      end
    end
  end

private

  def input_component
    render @input_component
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
