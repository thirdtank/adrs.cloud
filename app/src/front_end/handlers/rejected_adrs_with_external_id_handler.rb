class RejectedAdrsWithExternalIdHandler < AppHandler
  def initialize(external_id:, authenticated_account:, flash:)
    @external_id = external_id
    @authenticated_account = authenticated_account
    @flash = flash
  end

  def handle
    draft_adr = @authenticated_account.draft_adrs.find!(external_id: @external_id)
    draft_adr.reject!
    @flash.notice = :adr_rejected
    redirect_to(AdrsPage)
  end
end
