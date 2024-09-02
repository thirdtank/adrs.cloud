class AdrTagsWithExternalIdHandler < AppHandler
  def handle!(form:, account:, flash:)
    update_tags = Actions::Adrs::UpdateTags.new
    update_tags.update(form: form, account: account)
    flash[:notice] = "actions.adrs.tags_updated"
    redirect_to(AdrsByExternalIdPage, external_id: form.external_id)
  end
end
