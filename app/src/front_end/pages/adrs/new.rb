class Pages::Adrs::New < AppPage
  attr_reader :form
  def initialize(form:)
    @form = form
  end
end
