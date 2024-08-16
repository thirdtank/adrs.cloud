class Pages::Adrs::Edit < AppPage
  attr_reader :adr, :form, :error_message, :updated_message
  def initialize(adr:, form: nil, error_message: nil, updated_message: nil)
    @adr = adr
    @form = form || Forms::Adrs::Draft.from_adr(@adr)
    @error_message = error_message
    @updated_message = updated_message
  end

  def updated? = !@updated_message.nil?

end
