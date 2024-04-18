module MyHelpers

  def button(size: :normal, color: :gray, label:)
    %{
      <button class="button button--size--#{size} button--color--#{color}">
      #{label}
      </button>
    }.strip
  end

  def input_text(name:,autofocus: false, value: nil, required: false)
    text_field(type: :text, name: name, autofocus: autofocus, label: name, value: value, required: required)
  end

  def input_email(name:,autofocus: false, value: nil, required: false)
    text_field(type: :email, name: name, autofocus: autofocus, label: name, value: value, required: required)
  end

  def input_password(name:, value: nil, required: false)
    text_field(type: :password, name: name, autofocus: false, label: name, value: value, required: required)
  end

  def text_field(type:, name:, autofocus:, label:, value:, required:)
    %{
<label class="flex flex-column gap-1 w-100">
<input type="#{ type }" name="#{ name }" value="#{ value }" class="text-field" #{ autofocus ? "autofocus" : "" } #{required ? "required" : "" }>
  <div class="text-field-label">
  #{ label }
  </div>
</label>
    }
  end

  def form_field(form:, input:, autofocus: false, label: :derive, value: nil, default_type: "text", inner_label: false)
    input = input.to_s
    type = case form.class.inputs[input].type.name
           when Email.name
             "email"
           else
             default_type
           end
    name = input
    required = form.class.inputs[input].required?
    label = if label == :derive
              input.to_s
            else
              label
            end
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
    %{<textarea #{required ? 'required' : '' } rows="3" name="#{name}" class="textarea">#{ value ? value : "" }</textarea>}
    end
  end

  def textarea(name:, label:, value: false, required: false, inner_label: false)
    %{
      <label class="flex flex-column gap-1 w-100">
        <div class="textarea-container">
          #{ inner_label ? "<div class=\"inner-label\">#{inner_label}</div>" : '' }
          <textarea #{required ? 'required' : '' } rows="3" name="#{name}" class="textarea">#{ value ? value : "" }</textarea>
        </div>
        <div class="text-field-label">
          <span class="f-1">#{ label }</span>
        </div>
      </label>
    }
  end
end

module Components
  class BaseComponent < Brut::BaseComponent
    include MyHelpers
  end
end
module Pages
  class BasePage < Brut::BasePage
    include MyHelpers
  end
end
