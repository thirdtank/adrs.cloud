class Actions::Adrs::Reject < AppAction

  def call(form_submission:, account:)
    adr = DataModel::Adr[external_id: form_submission.external_id, account_id: account.id]
    if adr.accepted?
      raise "Accepted ADR may not be rejected"
    end
    adr.update(rejected_at: Time.now)
  end

end

