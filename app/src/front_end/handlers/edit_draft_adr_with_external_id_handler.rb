class EditDraftAdrWithExternalIdHandler < AppHandler
  def handle!(form:, account:, xhr:, flash:)
    action = Actions::Adrs::SaveDraft.new

    adr = action.update(form:,account:)
    if form.constraint_violations?
      if xhr
        [
          Adrs::ErrorMessagesComponent.new(form:),
          http_status(422),
        ]
      else
        EditDraftAdrByExternalIdPage.new(
          adr:,
          form:,
          flash:,
          error_message: "pages.adrs.edit.adr_invalid",
        )
      end
    else
      if xhr
        http_status(200)
      else
        flash[:notice] = "actions.adrs.updated"
        redirect_to(AdrsByExternalIdPage, external_id: adr.external_id)
      end
    end
  end
end
