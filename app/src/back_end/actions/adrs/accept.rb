class Actions::Adrs::Accept < AppAction
  class AcceptedAdrValidator < Brut::BackEnd::Actions::Validators::FormValidator
    validate :context   , required: true , minlength: 10
    validate :facing    , required: true , minlength: 10
    validate :decision  , required: true , minlength: 10
    validate :neglected , required: true , minlength: 10
    validate :achieve   , required: true , minlength: 10
    validate :accepting , required: true , minlength: 10
    validate :because   , required: true , minlength: 10
  end

  def accept(form:, account:)
    adr = DataModel::Adr[external_id: form.external_id, account_id: account.id]
    if !adr
      raise Brut::BackEnd::Errors::NotFound, "Account #{account.id} does not have an ADR with ID #{form.external_id}"
    end
    if form.constraint_violations?
      return adr
    end

    validator = AcceptedAdrValidator.new
    validator.validate(form)
    if form.constraint_violations?
      return adr
    end
    AppDataModel.transaction do
      if !adr.accepted?
        adr.update(title: form.title,
                   context: form.context,
                   facing: form.facing,
                   decision: form.decision,
                   neglected: form.neglected,
                   achieve: form.achieve,
                   accepting: form.accepting,
                   because: form.because,
                   tags: tag_serializer.from_string(form.tags),
                   accepted_at: Time.now,
                  )
      end
      if !adr.proposed_to_replace_adr.nil?
        if adr.proposed_to_replace_adr.accepted?
          adr.proposed_to_replace_adr.update(replaced_by_adr_id: adr.id)
        end
      end
    end
    adr
  end

private

  def tag_serializer
    @tag_serializer ||= Actions::Adrs::TagSerializer.new
  end
end
