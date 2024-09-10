class NewDraftAdrPage < AppPage
  attr_reader :form, :error_message, :refines_adr, :replaces_adr
  def initialize(form: nil, account:, flash:, account_entitlements:)
    @form                 = form || NewDraftAdrForm.new
    @account              = account
    @flash                = flash
    @account_entitlements = account_entitlements

    @error_message = if !@form.new? && form.constraint_violations?
                       :adr_invalid
                     else
                       nil
                     end
    @refines_adr  = AcceptedAdr.search(external_id: @form.refines_adr_external_id,account:)
    @replaces_adr = AcceptedAdr.search(external_id: @form.replaced_adr_external_id,account:)

  end

  def before_render
    if !@account_entitlements.can_add_new?
      @flash.alert = :add_new_limit_exceeded
      return redirect_to(AdrsPage)
    end
  end


end
