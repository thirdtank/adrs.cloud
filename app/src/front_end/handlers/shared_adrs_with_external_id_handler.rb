class SharedAdrsWithExternalIdHandler < AppHandler
  def handle(external_id:, authenticated_account:, flash:)
    accepted_adr = authenticated_account.accepted_adrs.find!(external_id:)
    accepted_adr.share!
    flash.notice = :adr_shared
    redirect_to(AdrsByExternalIdPage, external_id:)
  end
end
