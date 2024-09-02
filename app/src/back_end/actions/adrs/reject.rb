class Actions::Adrs::Reject < AppAction

  def reject(external_id:, account:)
    adr = DataModel::Adr[external_id: external_id, account_id: account.id]
    if !adr
      raise Brut::BackEnd::Errors::NotFound, "Account #{account.id} does not have an ADR with ID #{external_id}"
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

