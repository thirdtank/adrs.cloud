class EditDraftAdrByExternalIdPage < AppPage
  attr_reader :adr, :form, :error_message, :info_message
  def initialize(account:, external_id:, form: nil, flash:)
    @adr = DataModel::Adr[account_id: account.id, external_id: external_id]
    @form = form || EditDraftAdrWithExternalIdForm.from_adr(@adr)
    @error_message = flash[:error]
    @info_message = flash[:notice]
  end
end
