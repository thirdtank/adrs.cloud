class Actions::Adrs::SaveDraft
  def save_new(form:, account:)
    adr = DataModel::Adr.new(created_at: Time.now, account_id: account.id)

    save(form: form, adr: adr)
  end

  def update(form:, account:)
    if form.external_id.nil?
      raise Brut::BackEnd::Errors::Bug,
        "#{self.class.name} was attempted on a new ADR without an external id"
    end

    adr = DataModel::Adr[external_id: form.external_id, account_id: account.id]

    if !adr
      raise Brut::BackEnd::Errors::NotFound, "Account #{account.id} does not have an ADR with ID #{form.external_id}"
    end

    save(form: form, adr: adr)

  end

private

  def save(form:, adr:)
    result = create_result(form:form,adr:adr)
    if result.constraint_violations?
      return result
    end

    refines_adr = DataModel::Adr[external_id: form.refines_adr_external_id, account_id: adr.account.id]
    AppDataModel.transaction do
      adr.update(title: form.title,
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
      replaced_adr = DataModel::Adr[external_id: form.replaced_adr_external_id, account_id: adr.account.id]
      if replaced_adr
        DataModel::ProposedAdrReplacement.create(
          replacing_adr_id: adr.id,
          replaced_adr_id: replaced_adr.id,
          created_at: Time.now,
        )
      end
    end
    adr
  end

  def tag_serializer
    @tag_serializer ||= Actions::Adrs::TagSerializer.new
  end

  def create_result(form:,adr:)
    result = Brut::BackEnd::Actions::CheckResult.new
    if form.title.to_s.strip !~ /\s+/
      result.constraint_violation!(object: form, field: :title, key: :not_enough_words, context: { minwords: 2 })
    end
    result.save_context(adr:adr)
    result
  end
end
