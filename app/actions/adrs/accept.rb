class Actions::Adrs::Accept < AppAction
  class ServerSideValidator < Brut::Actions::Validators::DataObjectValidator
    validate :context   , required: true , minlength: 10
    validate :facing    , required: true , minlength: 10
    validate :decision  , required: true , minlength: 10
    validate :neglected , required: true , minlength: 10
    validate :achieve   , required: true , minlength: 10
    validate :accepting , required: true , minlength: 10
    validate :because   , required: true , minlength: 10
  end

  def call(form:, account:)
    adr = DataModel::Adr[external_id: form.external_id, account_id: account.id]
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
    adr
  end
end
