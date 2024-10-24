class RejectedAdrsWithExternalIdHandler < AppHandler
  def handle(external_id:, authenticated_account:, flash:)
    draft_adr = authenticated_account.draft_adrs.find!(external_id:)
    draft_adr.reject!
    flash.notice = :adr_rejected
    redirect_to(AdrsPage)
  end
end
