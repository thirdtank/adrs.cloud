class Actions::Adrs::Reject

  def reject(form:, account:)
    adr = DataModel::Adr[external_id: form.external_id, account_id: account.id]
    if !adr
      raise Brut::BackEnd::Errors::NotFound, "Account #{account.id} does not have an ADR with ID #{form.external_id}"
    end
    if adr.accepted?
      raise Brut::BackEnd::Errors::Bug, "ADR #{adr.external_id} has been accepted - this method should not have been called"
    end
    if !adr.rejected?
      adr.update(rejected_at: Time.now)
    end
    adr
  end
end

