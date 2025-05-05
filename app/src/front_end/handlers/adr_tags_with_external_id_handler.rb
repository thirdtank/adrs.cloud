class AdrTagsWithExternalIdHandler < AppHandler
  def initialize(form:, external_id:, authenticated_account:, flash:)
    @form = form
    @external_id = external_id
    @authenticated_account = authenticated_account
    @flash = flash
  end

  def handle
    accepted_adr = @authenticated_account.accepted_adrs.find!(external_id: @external_id)
    accepted_adr.update_tags(form: @form)
    @flash.notice = :tags_updated
    redirect_to(AdrsByExternalIdPage, external_id: @external_id)
  end
end
