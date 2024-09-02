class AcceptedAdrsWithExternalIdHandler < AppHandler
  def handle!(form:, account:, flash:)
    action = Actions::Adrs::Accept.new
    adr = action.accept(form:,account:)
    if form.constraint_violations?
      EditDraftAdrByExternalIdPage.new(
        adr:,
        form:,
        flash:,
        error_message: "pages.adrs.edit.adr_cannot_be_accepted",
      )
    else
      flash[:notice] = "actions.adrs.accepted"
      redirect_to(AdrsByExternalIdPage, external_id: adr.external_id)
    end
  end
end
