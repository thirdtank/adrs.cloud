class TextareaComponent < TextFieldComponent

private

  def input_component
    div(class: "textarea-container", data_invalid: invalid?) do
      render @input_component
    end
  end

  def create_input_component(form:,autofocus:,placeholder:,input_id:)
    input_html_attributes = {
      autofocus: autofocus,
      placeholder: placeholder,
      class: "textarea",
      rows: 5,
    }
    if input_id
      input_html_attributes.merge!(id: input_id)
    end
    Brut::FrontEnd::Components::Inputs::Textarea.for_form_input(
      form: form,
      input_name: @input_name,
      html_attributes: input_html_attributes,
    )
  end
end
