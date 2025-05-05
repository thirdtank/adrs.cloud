class ReplacedAdrsWithExistingExternalIdHandler < AppHandler
  def initialize(existing_external_id:, authenticated_account:, flash:)
    @existing_external_id = existing_external_id
    @authenticated_account = authenticated_account
    @flash = flash
  end

  def handle
    accepted_adr = @authenticated_account.accepted_adrs.find(external_id: @existing_external_id)
    form = NewDraftAdrForm.new(
      params: {
        replaced_adr_external_id: @existing_external_id,
        project_external_id: accepted_adr.project.external_id,
      }
    )
    NewDraftAdrPage.new(form: form, authenticated_account: @authenticated_account, flash: @flash)
  end
end
