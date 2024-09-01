class AdrTagsWithExternalIdForm < AppForm
  input :external_id, required: true
  input :tags, required: false

  def process!(account:, flash:)
    update_tags = Actions::Adrs::UpdateTags.new
    update_tags.update(form: self, account: account)
    flash[:notice] = "actions.adrs.tags_updated"
    redirect_to(AdrsByExternalIdPage, external_id: self.external_id)
  end
end

