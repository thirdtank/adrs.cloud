class ReplacedAdrsWithExistingExternalIdHandler < AppHandler
  def handle!(existing_external_id:, authenticated_account:, flash:)
    form = NewDraftAdrForm.new(
      params: {
        replaced_adr_external_id: existing_external_id
      }
    )
    NewDraftAdrPage.new(form:,authenticated_account:,flash:)
  end
end
