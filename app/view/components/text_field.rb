class Components::TextField < AppComponent
  attr_reader :label, :input, :error
  def initialize(label:,input: nil,form: nil, name: nil, autofocus: false)
    @label = label
    @input = input || html_input_for(form, name, html_attributes: { autofocus: autofocus, class: "text-field" })
    @error = if form.nil?
               []
             else
               validity = form[name].validity_state
               if validity.valid?
                 []
               else
                 validity
               end
             end
  end
end
