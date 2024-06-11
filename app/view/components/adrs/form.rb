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
      component(Components::Button.new(formaction: "/rejected_adrs", size: "small", color: "red", label: "Reject", icon: "recycle-bin-line-icon"))
    end
  end

  def accept_button
    if @form.external_id
      component(Components::Button.new(formaction: "/accepted_adrs", size: "small", color: "green", label: "Accept", icon: "quality-badge-checkmark-icon", confirm: "You won't be able to change this ADR after you accept it"))
    end
  end
end

