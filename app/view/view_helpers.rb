require_relative "components/text_field"
require_relative "components/button"

module ViewHelpers

  def button(size: :normal, color: :gray, label:)
    component(Button.new(size: size, color: color, label: label))
  end

  def text_field(form:, input:, autofocus: false, type: :derive)
    input = input.to_s
    input_class = form.class.inputs[input].type
    input_type = if type == :derive
                   input_class.input_type
                 else
                   type
                 end
    input_component = Brut::Input::TextField.new(
      form: form,
      input: input,
      type: input_type,
      attributes: {
        class: "text-field",
        autofocus: autofocus,
        pattern: input_class.respond_to?(:pattern) ? input_class.pattern : false,
      }
    )
    component(TextField.new(label: input.to_s, input: input_component))
  end

  class EmailComponent < Brut::BaseComponent
    def initialize(form:, name:, autofocus:, value:)
      @form = form
      @name = name
      @autofocus = autofocus
      @value = value
    end

    def render
      required = @form.class.inputs[@name].required?
      pattern = if @form.class.inputs[@name].type.respond_to?(:pattern)
                  "pattern='#{ @form.class.inputs[@name].type.pattern }'"
                else
                  nil
                end
      %{
         <input
          type="email"
          name="#{ @name }"
          value="#{ @value }" class="text-field" #{ @autofocus ? "autofocus" : "" } #{required ? "required" : "" } #{pattern}>
      }
    end
  end

  def form_field(form:, input:, autofocus: false, label: :derive, value: nil, default_type: "text", inner_label: false)
    input = input.to_s
    label = if label == :derive
              input
            else
              label
            end
    input_type = form.class.inputs[input].type.name
    if input_type == Email.name
      return component(
        TextField.new(
          label: label,
          input: EmailComponent.new(
            form: form,
            name: input,
            autofocus: autofocus,
            value: value,
          )
        )
      )
    end
    type = case form.class.inputs[input].type.name
           when Email.name
             "email"
           else
             default_type
           end
    name = input
    required = form.class.inputs[input].required?
    pattern = if form.class.inputs[input].type.respond_to?(:pattern)
                "pattern='#{ form.class.inputs[input].type.pattern }'"
              else
                nil
              end
    if type != "textarea"
      if inner_label
        raise "inner_label is only valid for a textarea"
      end
    %{
<label class="flex flex-column gap-1 w-100">
<input type="#{ type }" name="#{ name }" value="#{ value }" class="text-field" #{ autofocus ? "autofocus" : "" } #{required ? "required" : "" } #{pattern}>
  <div class="text-field-label">
  #{ label }
  </div>
</label>
    }
    else
    end
  end
end
