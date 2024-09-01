class AcceptedAdrsWithExternalIdForm < AppForm
  inputs_from NewDraftAdrForm
  input :external_id, required: false
  def new_record? = false

  def process!(account:, flash:)
    action = Actions::Adrs::Accept.new
    adr = action.accept(form: self, account: account)
    if self.constraint_violations?
      EditDraftAdrByExternalIdPage.new(
        adr: adr,
        form: self,
        error_message: "pages.adrs.edit.adr_cannot_be_accepted",
        flash: flash,
      )
    else
      flash[:notice] = "actions.adrs.accepted"
      redirect_to(AdrsByExternalIdPage, external_id: adr.external_id)
    end
  end
end
