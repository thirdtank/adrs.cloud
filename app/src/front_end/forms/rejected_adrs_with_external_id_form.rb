class RejectedAdrsWithExternalIdForm < AppForm
  input :external_id, required: false
  def new_record? = false

  def process!(account:, flash:)
    action = Actions::Adrs::Reject.new
    action.reject(form: self, account: account)
    flash[:notice] = "actions.adrs.rejected"
    redirect_to(AdrsPage)
  end
end
