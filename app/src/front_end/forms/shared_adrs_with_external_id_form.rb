class SharedAdrsWithExternalIdForm < AppForm
  input :external_id, required: true

  def process!(account:, flash:)
    Actions::Adrs::Share.new.share(external_id: self.external_id, account: )
    flash[:notice] = "actions.adrs.shared"
    redirect_to(AdrsByExternalIdPage, external_id: self.external_id)
  end
end
