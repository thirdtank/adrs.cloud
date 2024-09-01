class PrivateAdrsWithExternalIdForm < AppForm
  input :external_id, required: true

  def process!(account:, flash:)
    Actions::Adrs::Share.new.stop_sharing(external_id: self.external_id, account: )
    flash[:notice] = "actions.adrs.sharing_stopped"
    redirect_to(AdrsByExternalIdPage, external_id: self.external_id)
  end
end
