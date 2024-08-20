class Components::Adrs::ErrorMessages < AppComponent
  attr_reader :form
  def initialize(form:)
    @form = form
  end
end

