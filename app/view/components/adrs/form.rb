class Components::Adrs::Form < AppComponent
  def initialize(adr, action_label)
    @adr = adr
    @action_label = action_label
  end
  def adr = @adr
  def action_label = @action_label
  def adr_textarea(name:, prefix:, label:)
    component(Components::Adrs::Textarea.new(adr, name, prefix, label))
  end
end

