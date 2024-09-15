module Admin
  class AccountsByExternalIdPage < AppPage
    attr_reader :account, :form, :flash
    def initialize(external_id:, form: nil, flash:)
      @account = DataModel::Account[external_id: external_id]
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
end
