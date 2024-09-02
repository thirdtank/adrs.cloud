class NewDraftAdrHandler < AppHandler
  def handle!(form:, account:, flash:)
    action = Actions::Adrs::SaveDraft.new

    adr = action.save_new(form:,account:)
    if form.constraint_violations?
      flash[:error] = "pages.adrs.new.adr_invalid"
      NewDraftAdrPage.new(form:,account:)
    else
      flash[:notice] = "actions.adrs.created"
      redirect_to(EditDraftAdrByExternalIdPage, external_id: adr.external_id)
    end
  end

end
