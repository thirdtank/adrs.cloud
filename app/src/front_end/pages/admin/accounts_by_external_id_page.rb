module Admin
  class AccountsByExternalIdPage < AppPage
    attr_reader :account, :form, :flash
    def initialize(external_id:nil, form:nil, flash:)
      if external_id.nil? && form.nil?
        raise ArgumentError,"You must pass wither external_id or form to #{self.class}"
      elsif !external_id.nil? && !form.nil?
        raise ArgumentError,"You may not pass both external_id and form to #{self.class}"
      end

      external_id ||= form.external_id

      @account = DataModel::Account[external_id: external_id]
      @form = form || Admin::AccountEntitlementsWithExternalIdForm.new(params: {
        external_id: external_id,
        max_non_rejected_adrs: @account.entitlement.max_non_rejected_adrs,
      })
      @flash = flash
      if @form.constraint_violations?
        flash.alert = :entitlements_cannot_be_saved
      end
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
