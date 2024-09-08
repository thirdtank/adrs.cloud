class DraftAdr
  def self.create(account:)
    adr = DataModel::Adr.new(created_at: Time.now, account: account)
    DraftAdr.new(adr:)
  end

  def self.find(external_id:,account:)
    adr = DataModel::Adr[external_id: external_id, account: account, accepted_at: nil, rejected_at: nil]

    if !adr
      raise Brut::BackEnd::Errors::NotFound, "Account #{account.id} does not have an ADR with ID #{external_id}"
    end
    DraftAdr.new(adr:)
  end

  attr_reader :form

  def initialize(adr:)

    @adr  = adr
  end

  def external_id = @adr.external_id

  def accept(form:)
    AppDataModel.transaction do
      form = self.save(form:)
      if form.constraint_violations?
        return form
      end
      validator = AcceptedAdrValidator.new
      validator.validate(form)
      if form.constraint_violations?
        return form
      end
      if !@adr.accepted?
        @adr.update(accepted_at: Time.now)
      end
      if !@adr.proposed_to_replace_adr.nil?
        if @adr.proposed_to_replace_adr.accepted?
          @adr.proposed_to_replace_adr.update(replaced_by_adr_id: @adr.id)
        end
      end
    end
    form
  end

  class AcceptedAdrValidator < Brut::BackEnd::Validators::FormValidator
    validate :context   , required: true , minlength: 10
    validate :facing    , required: true , minlength: 10
    validate :decision  , required: true , minlength: 10
    validate :neglected , required: true , minlength: 10
    validate :achieve   , required: true , minlength: 10
    validate :accepting , required: true , minlength: 10
    validate :because   , required: true , minlength: 10
  end

  def reject!
    if @adr.accepted?
      raise Brut::BackEnd::Errors::Bug, "ADR #{@adr.external_id} has been accepted - this method should not have been called"
    end
    if !@adr.rejected?
      @adr.update(rejected_at: Time.now)
    end
  end

  def save(form:)
    if form.title.to_s.strip !~ /\s+/
      form.server_side_constraint_violation(input_name: :title, key: :not_enough_words, context: { minwords: 2 })
    end
    return form if form.constraint_violations?

    refines_adr = DataModel::Adr[external_id: form.refines_adr_external_id, account_id: @adr.account.id]
    AppDataModel.transaction do
      @adr.update(title: form.title,
                 context: form.context,
                 facing: form.facing,
                 decision: form.decision,
                 neglected: form.neglected,
                 achieve: form.achieve,
                 accepting: form.accepting,
                 because: form.because,
                 tags: Tags.from_string(string: form.tags).to_a,
                 refines_adr_id: refines_adr&.id,
                )
      replaced_adr = DataModel::Adr[external_id: form.replaced_adr_external_id, account_id: @adr.account.id]
      if replaced_adr
        DataModel::ProposedAdrReplacement.create(
          replacing_adr_id: @adr.id,
          replaced_adr_id: replaced_adr.id,
          created_at: Time.now,
        )
      end
    end
    form
  end
end

