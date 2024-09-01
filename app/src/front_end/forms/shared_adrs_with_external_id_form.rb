class SharedAdrsWithExternalIdForm < AppForm
  input :external_id, required: true

  def process!(account:, flash:)
    Actions::Adrs::Share.new.share(external_id: self.external_id, account: )
    flash[:notice] = "actions.adrs.shared"
    Brut::FrontEnd::FormProcessingResponse.redirect_to(Brut.container.routing.for(AdrsByExternalIdPage, external_id: self.external_id))
  end
end
