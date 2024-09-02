class RejectedAdrsWithExternalIdHandler < AppHandler
  def handle!(external_id:, account:, flash:)
    action = Actions::Adrs::Reject.new
    action.reject(external_id:,account:)
    flash[:notice] = "actions.adrs.rejected"
    redirect_to(AdrsPage)
  end
end
