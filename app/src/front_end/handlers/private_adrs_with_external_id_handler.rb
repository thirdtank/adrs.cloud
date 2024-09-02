class PrivateAdrsWithExternalIdHandler < AppHandler
  def handle!(external_id:, account:, flash:)
    Actions::Adrs::Share.new.stop_sharing(external_id:, account: )
    flash[:notice] = "actions.adrs.sharing_stopped"
    redirect_to(AdrsByExternalIdPage, external_id:)
  end
end
