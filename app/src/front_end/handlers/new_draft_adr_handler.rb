class NewDraftAdrHandler < AppHandler
  def handle(form:, authenticated_account:, flash:)
    if !authenticated_account.entitlements.can_add_new?
      return http_status(403)
    end

    draft_adr = DraftAdr.create(authenticated_account:)
    form = draft_adr.save(form:)

    if form.constraint_violations?
      flash.alert = :new_adr_invalid
      NewDraftAdrPage.new(form:,authenticated_account:,flash:)
    else
      flash.clear!
      flash.notice = :adr_created
      redirect_to(EditDraftAdrByExternalIdPage, external_id: draft_adr.external_id)
    end
  end
end
