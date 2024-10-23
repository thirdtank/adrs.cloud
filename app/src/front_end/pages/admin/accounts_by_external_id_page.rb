class Admin::AccountsByExternalIdPage < Admin::BasePage
  attr_reader :account, :form, :flash
  def initialize(authenticated_account:, external_id:, form: nil, flash:)
    super(authenticated_account:)
    @account = DB::Account.find!(external_id:)
    @form = form || Admin::AccountEntitlementsWithExternalIdForm.new(params: {
      max_non_rejected_adrs: @account.entitlement.max_non_rejected_adrs,
    })
    @flash = flash
    if @form.constraint_violations?
      flash.alert = :entitlements_cannot_be_saved
    end
  end

  def effective(method)
    override = @account.entitlement.send(method)
    if override.nil?
      @account.entitlement.entitlement_default.send(method)
    else
      override
    end
  end
end
