class DraftAdr

  class AcceptedAdrValidator < Brut::BackEnd::Validators::FormValidator
    validate :context   , required: true , minlength: 10
    validate :facing    , required: true , minlength: 10
    validate :decision  , required: true , minlength: 10
    validate :neglected , required: true , minlength: 10
    validate :achieve   , required: true , minlength: 10
    validate :accepting , required: true , minlength: 10
    validate :because   , required: true , minlength: 10
  end

  def self.create(account:)
    if !AccountEntitlements.new(account:).can_add_new?
      raise Brut::BackEnd::Errors::Bug, "#{account.external_id} has reached its plan limit - this should not have been called"
    end
    adr = DataModel::Adr.new(created_at: Time.now, account: account)
    DraftAdr.new(adr:)
  end

  def self.find(external_id:,account:)
    adr = DataModel::Adr.find!(external_id:, account:, accepted_at: nil, rejected_at: nil)

    if !adr
      raise Brut::BackEnd::Errors::NotFound, "Account #{account.id} does not have a draft ADR with ID #{external_id}"
    end
    DraftAdr.new(adr:)
  end

  attr_reader :form

  def initialize(adr:)
    @adr = adr
  end

  def external_id   =  @adr.external_id
  def refining?     = !self.adr_refining.nil?
  def replacing?    = !self.adr_replacing.nil?
  def adr_refining  =  @adr.refines_adr
  def adr_replacing =  @adr.proposed_to_replace_adr

  def to_params
    {
      title: @adr.title,
      context: @adr.context,
      facing: @adr.facing,
      decision: @adr.decision,
      neglected: @adr.neglected,
      achieve: @adr.achieve,
      accepting: @adr.accepting,
      because: @adr.because,
      tags: Tags.from_array(array: @adr.tags).to_s,
      refines_adr_external_id: @adr.refines_adr&.external_id,
    }
  end

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

    if form.constraint_violations?
      return form
    end


    AppDataModel.transaction do
      new_adr = @adr.external_id.nil?
      @adr.update(title: form.title,
                 context: form.context,
                 facing: form.facing,
                 decision: form.decision,
                 neglected: form.neglected,
                 achieve: form.achieve,
                 accepting: form.accepting,
                 because: form.because,
                 tags: Tags.from_string(string: form.tags).to_a,
                )

      if new_adr
        propose_replacement_adr(form)
        # XXX
        refines_adr = DataModel::Adr.find(external_id: form.refines_adr_external_id, account_id: @adr.account.id)
        @adr.update(refines_adr_id: refines_adr&.id)
      else
        replaced_adr_may_not_change!(form)
        refined_adr_may_not_change!(form)
      end
    end
    form
  end

private

  def propose_replacement_adr(form)
    if !form.replaced_adr_external_id.nil?
      accepted_adr_to_replace = AcceptedAdr.search(external_id: form.replaced_adr_external_id, account: @adr.account)
      adr_to_replace_must_exist!(accepted_adr_to_replace,form)
      accepted_adr_to_replace.propose_replacement(@adr)
    end
  end

  def replaced_adr_may_not_change!(form)
    form_replaced_adr_external_id     = form.replaced_adr_external_id
    proposed_replaced_adr_external_id = @adr.proposed_to_replace_adr&.external_id

    if !form_replaced_adr_external_id.nil? &&
        form_replaced_adr_external_id != proposed_replaced_adr_external_id
      raise Brut::BackEnd::Errors::Bug,"#{@adr.external_id} is proposed to replace #{proposed_replaced_adr_external_id || 'nothing'}, however the provided form has #{form_replaced_adr_external_id || 'nothing'} as the proposed replacement."
    end
  end
  def refined_adr_may_not_change!(form)
    form_refines_adr_external_id = form.refines_adr_external_id
    refines_adr_external_id      = @adr.refines_adr&.external_id

    if !form_refines_adr_external_id.nil? &&
        form_refines_adr_external_id != refines_adr_external_id
      raise Brut::BackEnd::Errors::Bug,"#{@adr.external_id} is refines #{refines_adr_external_id || 'nothing'}, however the provided form has #{form_refines_adr_external_id || 'nothing'} as the refinement."
    end
  end

  def adr_to_replace_must_exist!(accepted_adr_to_replace,form)
    if accepted_adr_to_replace.nil?
      raise Brut::BackEnd::Errors::Bug,"New ADR is proposed to replace #{form.replaced_adr_external_id}, however, that ADR does not exist in this account"
    end
  end
end
