class Actions::Adrs::Draft < Brut::Action
  class ServerSideValidator
    def validate(form_submission:,account:)
      if form_submission.title.to_s.strip !~ /\s+/
        return { title: "must be at least two words" }
      end
      {}
    end
  end

  def call(form_submission:, account:)
    if form_submission.external_id
      adr = DataModel::Adr[external_id: form_submission.external_id, account_id: account.id]
      if !adr
        raise "account does not have an ADR with that ID"
      end
    else
      adr = DataModel::Adr.new(created_at: Time.now)
    end
    adr.update(account_id: account.id,
               title: form_submission.title,
               context: form_submission.context,
               facing: form_submission.facing,
               decision: form_submission.decision,
               neglected: form_submission.neglected,
               achieve: form_submission.achieve,
               accepting: form_submission.accepting,
               because: form_submission.because,
              )
  end
end

