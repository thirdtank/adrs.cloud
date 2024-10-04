class NewDraftAdrPage < AppPage
  attr_reader :form, :refines_adr, :replaces_adr
  def initialize(form: nil, authenticated_account:, flash:)
    @form                 = form || NewDraftAdrForm.new
    @flash                = flash
    @account_entitlements = authenticated_account.entitlements

    @refines_adr  = authenticated_account.accepted_adrs.find(external_id: @form.refines_adr_external_id)
    @replaces_adr = authenticated_account.accepted_adrs.find(external_id: @form.replaced_adr_external_id)

    if !@form.new? && form.constraint_violations?
      @flash.alert = :adr_invalid
    end
  end

  def before_render
    if !@account_entitlements.can_add_new?
      @flash.alert = :add_new_limit_exceeded
      return redirect_to(AdrsPage)
    end
  end


end
