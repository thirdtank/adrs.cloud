class ReplacedAdrsWithExistingExternalIdForm < AppForm
  input :existing_external_id, required: true
  def process!(account:)
    form = NewDraftAdrForm.new(
      params: {
        replaced_adr_external_id: self.existing_external_id
      }
    )
    Brut::FrontEnd::FormProcessingResponse.render_page(NewDraftAdrPage.new(form: form, account: account))
  end
end
