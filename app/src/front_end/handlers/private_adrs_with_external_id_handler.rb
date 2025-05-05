class PrivateAdrsWithExternalIdHandler < AppHandler
  def initialize(external_id:, authenticated_account:, flash:)
    @external_id = external_id
    @authenticated_account = authenticated_account
    @flash = flash
  end

  def handle
    accepted_adr = @authenticated_account.accepted_adrs.find!(external_id: @external_id)
    accepted_adr.stop_sharing!
    @flash.notice = :sharing_stopped
    redirect_to(AdrsByExternalIdPage, external_id: @external_id)
  end
end
