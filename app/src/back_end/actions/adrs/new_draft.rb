class Actions::Adrs::NewDraft < Actions::Adrs::SaveDraft

  def check(form:, account:)
    if form.external_id
      raise "#{self.class.name} was attempted on an existing ADR with external id #{form.external_id}"
    end
    result = self.check_result
    if form.title.to_s.strip !~ /\s+/
      result.constraint_violation!(object: form, field: :title, key: :not_enough_words, context: { minwords: 2 })
    end
    result.save_context(adr: DataModel::Adr.new(created_at: Time.now, account_id: account.id))
    result
  end
end

