module Admin
  class AccountsByExternalIdPage < AppPage
    attr_reader :account, :form
    def initialize(external_id:)
      @account = DataModel::Account[external_id: external_id]
      @form = Admin::AccountEntitlementsWithExternalIdForm.new(params: {
        external_id: external_id,
        max_non_rejected_adrs: @account.entitlement.max_non_rejected_adrs,
      })
    end

    def or_none(value)
      value || "NONE"
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
