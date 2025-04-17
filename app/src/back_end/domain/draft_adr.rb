class DraftAdr

  include Brut::Framework::Errors
  extend Brut::Framework::Errors
  include Brut::Instrumentation

  class AcceptedAdrValidator < Brut::BackEnd::Validators::FormValidator
    validate :context   , required: true , minlength: 10
    validate :facing    , required: true , minlength: 10
    validate :decision  , required: true , minlength: 10
    validate :neglected , required: true , minlength: 10
    validate :achieve   , required: true , minlength: 10
    validate :accepting , required: true , minlength: 10
    validate :because   , required: true , minlength: 10
  end

  def self.create(authenticated_account:)
    if !authenticated_account.entitlements.can_add_new?
      bug! "#{authenticated_account.account.external_id} has reached its plan limit - this should not have been called"
    end
    adr = DB::Adr.new(account: authenticated_account.account)
    DraftAdr.new(adr:)
  end

  def self.find!(external_id:,account:)
    adr = DB::Adr.find!(external_id:, account:, accepted_at: nil, rejected_at: nil)

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
  def project       =  @adr.project

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
      project_external_id: @adr.project.external_id,
    }
  end

  def accept(form:)
    DB.transaction do
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
        DB.transaction do
          @adr.update(accepted_at: Time.now)
          if @adr.project.adrs_shared_by_default
            AcceptedAdr.new(adr:@adr).share!
          end
        end
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
      bug! "ADR #{@adr.external_id} has been accepted - this method should not have been called"
    end
    if !@adr.rejected?
      @adr.update(rejected_at: Time.now)
    end
  end

  def save(form:)
    span("DraftAdr.save") do |span|
      if form.title.to_s.strip !~ /\s+/
        form.server_side_constraint_violation(input_name: :title, key: :not_enough_words, context: { minwords: 2 })
      end

      if form.constraint_violations?
        span.add_attributes(constraint_violations: true)
      else
        project = DB::Project.find!(external_id: form.project_external_id)
        if project.account != @adr.account
          bug! "Project #{form.project_external_id}'s account does not belong to account #{@adr.account.external_id}"
        end

        DB.transaction do
          new_adr = @adr.external_id.nil?
          @adr.update(title: form.title,
                      context: form.context,
                      facing: form.facing,
                      decision: form.decision,
                      neglected: form.neglected,
                      achieve: form.achieve,
                      accepting: form.accepting,
                      because: form.because,
                      project: project,
                      tags: Tags.from_string(string: form.tags).to_a,
                     )

          if new_adr
            span.add_attributes(id: :new)
            propose_replacement_adr(form)
            refines_adr = DB::Adr.find(external_id: form.refines_adr_external_id, account_id: @adr.account.id)
            if refines_adr && refines_adr.project != project
              bug! "Project #{form.project_external_id}'s is not the same as the ADR being refined's project #{refines_adr.project.external_id}"
            end
            @adr.update(refines_adr_id: refines_adr&.id)
          else
            span.add_attributes(id: @adr.external_id)
            replaced_adr_may_not_change!(form)
            refined_adr_may_not_change!(form)
          end
        end
      end
      form
    end
  end

private

  def propose_replacement_adr(form)
    if !form.replaced_adr_external_id.nil?
      authenticated_account = AuthenticatedAccount.new(account: @adr.account)
      accepted_adr_to_replace = authenticated_account.accepted_adrs.find(external_id: form.replaced_adr_external_id)
      adr_to_replace_must_exist!(accepted_adr_to_replace,form)
      accepted_adr_to_replace.propose_replacement(@adr)
    end
  end

  def replaced_adr_may_not_change!(form)
    form_replaced_adr_external_id     = form.replaced_adr_external_id
    proposed_replaced_adr_external_id = @adr.proposed_to_replace_adr&.external_id

    if !form_replaced_adr_external_id.nil? &&
        form_replaced_adr_external_id != proposed_replaced_adr_external_id
      bug! "#{@adr.external_id} is proposed to replace #{proposed_replaced_adr_external_id || 'nothing'}, however the provided form has #{form_replaced_adr_external_id || 'nothing'} as the proposed replacement."
    end
  end
  def refined_adr_may_not_change!(form)
    form_refines_adr_external_id = form.refines_adr_external_id
    refines_adr_external_id      = @adr.refines_adr&.external_id

    if !form_refines_adr_external_id.nil? &&
        form_refines_adr_external_id != refines_adr_external_id
      bug! "#{@adr.external_id} is refines #{refines_adr_external_id || 'nothing'}, however the provided form has #{form_refines_adr_external_id || 'nothing'} as the refinement."
    end
  end

  def adr_to_replace_must_exist!(accepted_adr_to_replace,form)
    if accepted_adr_to_replace.nil?
      bug! "New ADR is proposed to replace #{form.replaced_adr_external_id}, however, that ADR does not exist in this account"
    end
  end
end
