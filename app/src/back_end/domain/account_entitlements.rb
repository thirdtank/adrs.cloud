class AccountEntitlements
  def self.find!(external_id:)
    self.new(account:DB::Account.find!(external_id:))
  end

  def initialize(account:)
    @account = account
  end

  def grant_for_new_user
    if !@account.entitlement.nil?
      raise Brut::BackEnd::Errors::Bug,"#{@account.external_id} already has entitlements"
    end
    default = DB::EntitlementDefault.find!(internal_name: "basic")
    DB::Entitlement.create(account: @account, entitlement_default: default)
  end

  def admin?
    if @account.entitlement.admin.nil?
      @account.entitlement.entitlement_default.admin
    else
      @account.entitlement.admin
    end
  end

  def can_add_new?
    non_rejected_adrs < max_non_rejected_adrs
  end

  def update(form:)
    if form.constraint_violations?
      return form
    end
    @account.entitlement.update(max_non_rejected_adrs: form.max_non_rejected_adrs)
    form
  end

  def max_non_rejected_adrs
    @max_non_rejected_adrs ||= (
      @account.entitlement.max_non_rejected_adrs ||
      @account.entitlement.entitlement_default.max_non_rejected_adrs
    )
  end

  def non_rejected_adrs
    @non_rejected_adrs ||= @account.adrs_dataset.where(rejected_at: nil).count
  end

  def non_rejected_adrs_remaining
    max_non_rejected_adrs - non_rejected_adrs
  end

  def can_add_new_project?
    num_projects < max_projects
  end

  def max_projects
    @max_projects ||= (
      @account.entitlement.max_projects ||
      @account.entitlement.entitlement_default.max_projects
    )
  end

  def num_projects
    @projects ||= @account.projects_dataset.count
  end

  def projects_remaining
    max_projects - num_projects
  end
end
