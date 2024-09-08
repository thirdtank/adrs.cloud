class NewDraftAdrHandler < AppHandler
  def handle!(form:, account:, flash:)
    draft_adr = DraftAdr.create(account:)
    form = draft_adr.save(form:)

    if form.constraint_violations?
      flash.alert = :adr_invalid
      NewDraftAdrPage.new(form:,account:)
    else
      flash.notice = :adr_created
      redirect_to(EditDraftAdrByExternalIdPage, external_id: draft_adr.external_id)
    end
  end
end
