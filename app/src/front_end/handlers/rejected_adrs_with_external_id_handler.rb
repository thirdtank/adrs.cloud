class RejectedAdrsWithExternalIdHandler < AppHandler
  def handle!(external_id:, account:, flash:)
    draft_adr = DraftAdr.find(external_id:,account:)
    draft_adr.reject!
    flash.notice = :adr_rejected
    redirect_to(AdrsPage)
  end
end
