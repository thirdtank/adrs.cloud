class Actions::Adrs::EditDraft < Actions::Adrs::SaveDraft

  def check(form:, account:)
    if form.external_id.nil?
      raise "#{self.class.name} was attempted on a new ADR without an external id"
    end

    adr = DataModel::Adr[external_id: form.external_id, account_id: account.id]

    if !adr
      raise "account does not have an ADR with that ID"
    end

    result = self.check_result
    if form.title.to_s.strip !~ /\s+/
      result.constraint_violation!(object: form, field: :title, key: :not_enough_words, context: { minwords: 2 })
    end
    result.save_context(adr:adr)
    result
  end


end

