class Pages::Adrs::Replace < Pages::Adrs::New
  def initialize(form:, account:)
    super(form: form)
    @account = account
  end

  def replaced_adr
    @replaced_adr ||= DataModel::Adr[external_id: form.replaced_adr_external_id, account_id: @account.id]
  end
end

