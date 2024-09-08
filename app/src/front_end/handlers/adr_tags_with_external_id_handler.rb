class AdrTagsWithExternalIdHandler < AppHandler
  def handle!(form:, account:, flash:)
    accepted_adr = AcceptedAdr.find(external_id: form.external_id,account:)
    accepted_adr.update_tags(form:)
    flash[:notice] = :tags_updated
    redirect_to(AdrsByExternalIdPage, external_id: form.external_id)
  end

end
