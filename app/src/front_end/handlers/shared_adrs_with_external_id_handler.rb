class SharedAdrsWithExternalIdHandler < AppHandler
  def handle!(external_id:, account:, flash:)
    accepted_adr = AcceptedAdr.find(external_id:,account:)
    accepted_adr.share!
    flash[:notice] = :adr_shared
    redirect_to(AdrsByExternalIdPage, external_id:)
  end
end
