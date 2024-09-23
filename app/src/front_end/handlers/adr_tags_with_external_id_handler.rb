class AdrTagsWithExternalIdHandler < AppHandler
  def handle!(form:, external_id:, authenticated_account:, flash:)
    accepted_adr = authenticated_account.accepted_adrs.find!(external_id:)
    accepted_adr.update_tags(form:)
    flash.notice = :tags_updated
    redirect_to(AdrsByExternalIdPage, external_id:)
  end

end
