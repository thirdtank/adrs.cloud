class SharedAdrsWithExternalIdHandler < AppHandler
  def handle!(external_id:, account:, flash:)
    Actions::Adrs::Share.new.share(external_id:, account: )
    flash[:notice] = :adr_shared
    redirect_to(AdrsByExternalIdPage, external_id:)
  end
end
