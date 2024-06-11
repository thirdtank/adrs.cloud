class Pages::Adrs::Edit < AppPage
  attr_reader :adr, :form, :error_message
  def initialize(adr:, form: nil, error_message: nil)
    @adr = adr
    @form = form || Forms::Adrs::Draft.from_adr(@adr)
    @error_message = error_message
  end

  def adr_path(adr) = "/adrs/#{adr.external_id}"
end
