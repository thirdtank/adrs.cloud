class RejectedAdrsWithExternalIdHandler < AppHandler
  def handle!(external_id:, account:, flash:)
    action = Actions::Adrs::Reject.new
    action.reject(external_id:,account:)
    flash[:notice] = :adr_rejected
    redirect_to(AdrsPage)
  end
end
