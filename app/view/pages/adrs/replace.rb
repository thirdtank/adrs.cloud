class Pages::Adrs::Replace < Pages::Adrs::New
  def initialize(form:, account:)
    super(content: form)
    @account = account
  end

  def replaced_adr
    @replaced_adr ||= DataModel::Adr[external_id: adr.replaced_adr_external_id, account_id: @account.id]
  end
end

