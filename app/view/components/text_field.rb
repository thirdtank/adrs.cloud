class Components::TextField < AppComponent
  attr_reader :label, :input
  def initialize(label:,input:)
    @label = label
    @input = input
  end
end
