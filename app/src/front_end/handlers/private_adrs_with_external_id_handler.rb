class PrivateAdrsWithExternalIdHandler < AppHandler
  def handle!(external_id:, authenticated_account:, flash:)
    accepted_adr = authenticated_account.accepted_adrs.find!(external_id:)
    accepted_adr.stop_sharing!
    flash.notice = :sharing_stopped
    redirect_to(AdrsByExternalIdPage, external_id:)
  end
end
