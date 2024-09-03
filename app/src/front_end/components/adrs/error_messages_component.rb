class Adrs::ErrorMessagesComponent < AppComponent
  attr_reader :form
  def initialize(form:)
    @form = form
  end
end

