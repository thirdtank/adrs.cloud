class Actions::Adrs::Accept
  class AcceptedAdrValidator < Brut::BackEnd::Actions::Validators::DataObjectValidator
    validate :context   , required: true , minlength: 10
    validate :facing    , required: true , minlength: 10
    validate :decision  , required: true , minlength: 10
    validate :neglected , required: true , minlength: 10
    validate :achieve   , required: true , minlength: 10
    validate :accepting , required: true , minlength: 10
    validate :because   , required: true , minlength: 10
  end

  def accept(form:, account:)
    result = Brut::BackEnd::Actions::CheckResult.new
    adr = DataModel::Adr[external_id: form.external_id, account_id: account.id]
    if !adr
      raise "This account cannot access this ADR"
    end
    result.save_context(adr: adr)
    validator = AcceptedAdrValidator.new
    validator.validate(form,result)
    if result.constraint_violations?
      return result
    end
    adr = result[:adr]
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
