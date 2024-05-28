class Components::Adrs::Form < AppComponent
  def initialize(adr, action_label)
    @adr = adr
    @action_label = action_label
  end
  def adr = @adr
  def action_label = @action_label
  def adr_textarea(name:, prefix:, label:)
    component(Components::Adrs::Textarea.new(form: adr, input_name: name, prefix: prefix, label: label))
  end

  def reject_button
    if @adr.external_id
      component(Components::Button.new(formaction: "/rejected_adrs", size: "small", color: "red", label: "Reject", icon: "recycle-bin-line-icon"))
    end
  end

  def accept_button
    if @adr.external_id
      component(Components::Button.new(formaction: "/accepted_adrs", size: "small", color: "green", label: "Accept", icon: "quality-badge-checkmark-icon", confirm: "You won't be able to change this ADR after you accept it"))
    end
  end
end

