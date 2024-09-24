class RefinedAdrsWithExistingExternalIdHandler < AppHandler
  def handle!(existing_external_id:,authenticated_account:)
    form = NewDraftAdrForm.new(
      params: {
        refines_adr_external_id: existing_external_id
      }
    )
    NewDraftAdrPage.new(form:,authenticated_account:)
  end
end
