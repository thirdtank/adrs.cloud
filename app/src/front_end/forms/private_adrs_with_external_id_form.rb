class PrivateAdrsWithExternalIdForm < AppForm
  input :external_id, required: true

  def process!(account:, flash:)
    Actions::Adrs::Share.new.stop_sharing(external_id: self.external_id, account: )
    flash[:notice] = "actions.adrs.sharing_stopped"
    Brut::FrontEnd::FormProcessingResponse.redirect_to(Brut.container.routing.for(AdrsByExternalIdPage, external_id: self.external_id))
  end
end
