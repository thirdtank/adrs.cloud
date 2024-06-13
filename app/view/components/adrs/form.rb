class Components::Adrs::Form < AppComponent
  attr_reader :form
  def initialize(form, action_label)
    @form = form
    @action_label = action_label
  end
  def action_label = @action_label
  def adr_textarea(name:, prefix:, label:)
    component(Components::Adrs::Textarea.new(form: @form, input_name: name, prefix: prefix, label: label))
  end

  def reject_button
    if @form.external_id
      component(Components::Button.new(formaction: "/rejected_adrs", size: "small", color: "red", label: "Reject ADR", icon: "recycle-bin-line-icon", confirm: "You can't bring this back other than re-creating it by hand"))
    end
  end

  def accept_button
    if @form.external_id
      component(Components::Button.new(formaction: "/accepted_adrs", size: "small", color: "green", label: "Accept ADR", icon: "quality-badge-checkmark-icon", confirm: "You won't be able to change this ADR after you accept it"))
    end
  end
end

