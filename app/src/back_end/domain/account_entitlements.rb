class AccountEntitlements
  def self.find(external_id:)
    self.new(account:DataModel::Account.find!(external_id:))
  end


  def initialize(account:)
    @account = account
  end

  def grant_for_new_user
    if !@account.entitlement.nil?
      raise Brut::BackEnd::Errors::Bug,"#{@account.external_id} already has entitlements"
    end
    default = DataModel::EntitlementDefault.find!(internal_name: "basic")
    DataModel::Entitlement.create(account: @account, entitlement_default: default, created_at: Time.now)
  end


  def can_add_new?
    AccountAdrs.num_non_rejected(account: @account) < max_non_rejected_adrs
  end

  def update(form:)
    if form.constraint_violations?
      return form
    end
    @account.entitlement.update(max_non_rejected_adrs: form.max_non_rejected_adrs)
    form
  end

private

  def max_non_rejected_adrs
    @account.entitlement.max_non_rejected_adrs ||
      @account.entitlement.entitlement_default.max_non_rejected_adrs
  end
end
