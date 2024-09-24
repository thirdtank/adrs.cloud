class EditDraftAdrByExternalIdPage < AppPage
  attr_reader :draft_adr, :form, :error_message, :info_message
  def initialize(authenticated_account:, external_id:, form: nil, flash:)
    @draft_adr     = authenticated_account.draft_adrs.find!(external_id:)
    @form          = form || EditDraftAdrWithExternalIdForm.new(params: @draft_adr.to_params)
    @error_message = flash.alert
    @info_message  = flash.notice
  end
end
