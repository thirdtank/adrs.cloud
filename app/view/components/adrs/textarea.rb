class Components::Adrs::Textarea < AppComponent
  attr_reader :adr, :name, :prefix, :label
  def initialize(adr, name, prefix, label)
    @adr = adr
    @name = name
    @prefix = prefix
    @label = label
  end
end

