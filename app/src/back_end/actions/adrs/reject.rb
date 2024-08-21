class Actions::Adrs::Reject

  def reject(form:, account:)
    adr = DataModel::Adr[external_id: form.external_id, account_id: account.id]
    if !adr
      raise "account does not have an ADR with that ID"
    end
    if adr.accepted?
      raise "Accepted ADR may not be rejected"
    end
    adr.update(rejected_at: Time.now)
    adr
  end

end

