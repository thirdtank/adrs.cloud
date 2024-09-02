class RefinedAdrsWithExistingExternalIdHandler < AppHandler
  def handle!(existing_external_id:,account:)
    form = NewDraftAdrForm.new(
      params: {
        refines_adr_external_id: existing_external_id
      }
    )
    NewDraftAdrPage.new(form:,account:)
  end
end
