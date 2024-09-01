class RefinedAdrsWithExistingExternalIdForm < AppForm
  input :existing_external_id, required: true

  def process!(account:)
    form = NewDraftAdrForm.new(
      params: {
        refines_adr_external_id: self.existing_external_id
      }
    )
    NewDraftAdrPage.new(form: form, account: account)
  end
end
