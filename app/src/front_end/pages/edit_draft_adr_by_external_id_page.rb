class EditDraftAdrByExternalIdPage < AppPage
  attr_reader :draft_adr, :form
  def initialize(authenticated_account:, external_id:, form: nil)
    @draft_adr     = authenticated_account.draft_adrs.find!(external_id:)
    @form          = form || EditDraftAdrWithExternalIdForm.new(params: @draft_adr.to_params)
  end
end
