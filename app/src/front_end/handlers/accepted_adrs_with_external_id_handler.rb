class AcceptedAdrsWithExternalIdHandler < AppHandler
  def handle!(form:, external_id:, account:, flash:)
    draft_adr = DraftAdr.find(account:,external_id:)

    form = draft_adr.accept(form:)

    if form.constraint_violations?
      flash.alert = :adr_cannot_be_accepted
      EditDraftAdrByExternalIdPage.new(
        form:,
        flash:,
        account:,
        external_id: draft_adr.external_id,
      )
    else
      flash.notice = :adr_accepted
      redirect_to(AdrsByExternalIdPage, external_id: draft_adr.external_id)
    end
  end
end
