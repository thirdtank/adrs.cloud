class AccountEntitlements
  def initialize(account:)
    @account = account
  end

  def can_add_new?
    AccountAdrs.num_non_rejected(account: @account) < max_non_rejected_adrs
  end

private

  def max_non_rejected_adrs
    @account.entitlement.max_non_rejected_adrs ||
      @account.entitlement.entitlement_default.max_non_rejected_adrs
  end
end
