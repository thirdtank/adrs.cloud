class Pages::Adrs::Refine < Pages::Adrs::New
  def initialize(form:, account:)
    super(content: form)
    @account = account
  end

  def refined_adr
    @refined_adr ||= DataModel::Adr[external_id: adr.refines_adr_external_id, account_id: @account.id]
  end
end

