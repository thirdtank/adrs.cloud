class Actions::Adrs::NewDraft < AppAction

  def check(form:, account:)
    if form.external_id
      raise "#{self.class.name} was attempted on an existing ADR with external id #{form.external_id}"
    end
    result = self.check_result
    if form.title.to_s.strip !~ /\s+/
      result.constraint_violation!(object: form, field: :title, key: :not_enough_words, context: 2)
    end
    result
  end

  def call(form:, account:)
    result = self.check(form: form, account: account)
    if !result.can_call?
      return result
    end
    adr = DataModel::Adr.new(created_at: Time.now)

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
    result.save_context(adr: adr)
    result
  end

private

  def tag_serializer
    @tag_serializer ||= Actions::Adrs::TagSerializer.new
  end
end

