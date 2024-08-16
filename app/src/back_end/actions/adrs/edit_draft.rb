class Actions::Adrs::EditDraft < AppAction

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
      result.constraint_violation!(object: form, field: :title, key: :not_enough_words, context: 2)
    end
    result.save_context(adr:adr)
    result
  end

  def call(form:, account:)
    result = self.check(form: form, account: account)
    if !result.can_call?
      return result
    end

    adr = result[:adr]

    refines_adr = DataModel::Adr[external_id: form.refines_adr_external_id, account_id: account.id]
    AppDataModel.transaction do
      adr.update(account_id: account.id,
                 title: form.title,
                 context: form.context,
                 facing: form.facing,
                 decision: form.decision,
                 neglected: form.neglected,
                 achieve: form.achieve,
                 accepting: form.accepting,
                 because: form.because,
                 tags: tag_serializer.from_string(form.tags),
                 refines_adr_id: refines_adr&.id,
                )
      replaced_adr = DataModel::Adr[external_id: form.replaced_adr_external_id, account_id: account.id]
      if replaced_adr
        DataModel::ProposedAdrReplacement.create(
          replacing_adr_id: adr.id,
          replaced_adr_id: replaced_adr.id,
          created_at: Time.now,
        )
      end
    end
    result
  end

private

  def tag_serializer
    @tag_serializer ||= Actions::Adrs::TagSerializer.new
  end
end

