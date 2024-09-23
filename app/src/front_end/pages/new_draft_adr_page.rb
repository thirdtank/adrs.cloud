class NewDraftAdrPage < AppPage
  attr_reader :form, :error_message, :refines_adr, :replaces_adr
  def initialize(form: nil, authenticated_account:, flash:)
    @form                 = form || NewDraftAdrForm.new
    @flash                = flash
    @account_entitlements = authenticated_account.entitlements

    @error_message = if !@form.new? && form.constraint_violations?
                       :adr_invalid
                     else
                       nil
                     end
    @refines_adr  = authenticated_account.accepted_adrs.find(external_id: @form.refines_adr_external_id)
    @replaces_adr = authenticated_account.accepted_adrs.find(external_id: @form.replaced_adr_external_id)

  end

  def before_render
    if !@account_entitlements.can_add_new?
      @flash.alert = :add_new_limit_exceeded
      return redirect_to(AdrsPage)
    end
  end


end
