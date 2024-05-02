class Actions::Adrs::Accept < AppAction
  class ServerSideValidator
    class AcceptedAdrValidator < Brut::Actions::Validators::DataObjectValidator
      validate :context   , required: true , minlength: 10
      validate :facing    , required: true , minlength: 10
      validate :decision  , required: true , minlength: 10
      validate :neglected , required: true , minlength: 10
      validate :achieve   , required: true , minlength: 10
      validate :accepting , required: true , minlength: 10
      validate :because   , required: true , minlength: 10
    end

    def validate(form_submission:,account:)
      adr = DataModel::Adr[external_id: form_submission.external_id, account_id: account.id]
      if !adr
        raise "account does not have an ADR with that ID"
      end
      AcceptedAdrValidator.new.validate(adr)
    end
  end

  def call(form_submission:, account:)
    if !adr.accepted?
      adr.update(accepted_at: Time.now)
    end
  end

end
