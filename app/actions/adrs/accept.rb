class Actions::Adrs::Accept < AppAction
  class AcceptedAdrValidator < Brut::Actions::Validators::DataObjectValidator
    validate :context   , required: true , minlength: 10
    validate :facing    , required: true , minlength: 10
    validate :decision  , required: true , minlength: 10
    validate :neglected , required: true , minlength: 10
    validate :achieve   , required: true , minlength: 10
    validate :accepting , required: true , minlength: 10
    validate :because   , required: true , minlength: 10
  end

  def check(form:, account:)
    result = self.check_result
    adr = DataModel::Adr[external_id: form.external_id, account_id: account.id]
    if !adr
      raise "This account cannot access this ADR"
    end
    result.save_context(adr: adr)
    validator = AcceptedAdrValidator.new
    validator.validate(form,result)
    result
  end

  def call(form:, account:)
    result = self.check(form: form, account: account)
    return result if !result.can_call?
    adr = result[:adr]
    if !adr.accepted?
      adr.update(title: form.title,
                 context: form.context,
                 facing: form.facing,
                 decision: form.decision,
                 neglected: form.neglected,
                 achieve: form.achieve,
                 accepting: form.accepting,
                 because: form.because,
                 accepted_at: Time.now,
                )
    end
    result
  end
end
