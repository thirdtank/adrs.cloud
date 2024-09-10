class NewDraftAdrHandler < AppHandler
  def handle!(form:, account:, flash:, account_entitlements:)
    if !account_entitlements.can_add_new?
      return http_status(403)
    end

    draft_adr = DraftAdr.create(account:)
    form = draft_adr.save(form:)

    if form.constraint_violations?
      flash.alert = :adr_invalid
      NewDraftAdrPage.new(form:,account:,flash:, account_entitlements:)
    else
      flash.notice = :adr_created
      redirect_to(EditDraftAdrByExternalIdPage, external_id: draft_adr.external_id)
    end
  end
end
