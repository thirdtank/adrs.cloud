class EditDraftAdrWithExternalIdHandler < AppHandler
  def handle(form:, external_id:, authenticated_account:, xhr:, flash:)
    draft_adr = authenticated_account.draft_adrs.find!(external_id:external_id)
    form = draft_adr.save(form:)

    if form.constraint_violations?
      if xhr
        [
          ErrorMessagesComponent.new(form:),
          http_status(422),
        ]
      else
        flash.alert = :update_adr_invalid
        EditDraftAdrByExternalIdPage.new(
          form:,
          authenticated_account:,
          external_id: draft_adr.external_id,
        )
      end
    else
      if xhr
        http_status(200)
      else
        flash.notice = :adr_updated
        redirect_to(AdrsByExternalIdPage, external_id: draft_adr.external_id)
      end
    end
  end
end
