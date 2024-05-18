class Actions::Adrs::Draft < Brut::Action
  class ServerSideValidator
    def validate(form:,account:)
      if form.title.to_s.strip !~ /\s+/
        form.server_side_constraint_violation(input_name: :title, key: :not_enough_words, context: 2)
      end
    end
  end

  def call(form:, account:)
    if form.external_id
      adr = DataModel::Adr[external_id: form.external_id, account_id: account.id]
      if !adr
        raise "account does not have an ADR with that ID"
      end
    else
      adr = DataModel::Adr.new(created_at: Time.now)
    end
    adr.update(account_id: account.id,
               title: form.title,
               context: form.context,
               facing: form.facing,
               decision: form.decision,
               neglected: form.neglected,
               achieve: form.achieve,
               accepting: form.accepting,
               because: form.because,
              )
  end
end

