class PrivateAdrsWithExternalIdHandler < AppHandler
  def handle!(external_id:, account:, flash:)
    accepted_adr = AcceptedAdr.find(external_id:,account:)
    accepted_adr.stop_sharing!
    flash[:notice] = :sharing_stopped
    redirect_to(AdrsByExternalIdPage, external_id:)
  end
end
