class EditDraftAdrWithExternalIdHandler < AppHandler
  def handle!(form:, account:, xhr:, flash:)
    draft_adr = DraftAdr.find(external_id:form.external_id, account:)
    form = draft_adr.save(form:)

    if form.constraint_violations?
      if xhr
        [
          Adrs::ErrorMessagesComponent.new(form:),
          http_status(422),
        ]
      else
        flash[:error] = :adr_invalid
        EditDraftAdrByExternalIdPage.new(
          form:,
          flash:,
          account:,
          external_id: draft_adr.external_id,
        )
      end
    else
      if xhr
        http_status(200)
      else
        flash[:notice] = :adr_updated
        redirect_to(AdrsByExternalIdPage, external_id: draft_adr.external_id)
      end
    end
  end
end
