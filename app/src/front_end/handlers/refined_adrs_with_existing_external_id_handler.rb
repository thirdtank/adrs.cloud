class RefinedAdrsWithExistingExternalIdHandler < AppHandler
  def handle(existing_external_id:,authenticated_account:,flash:)
    accepted_adr = authenticated_account.accepted_adrs.find(external_id: existing_external_id)
    form = NewDraftAdrForm.new(
      params: {
        refines_adr_external_id: existing_external_id,
        project_external_id: accepted_adr.project.external_id,
      }
    )
    NewDraftAdrPage.new(form:,authenticated_account:,flash:)
  end
end
