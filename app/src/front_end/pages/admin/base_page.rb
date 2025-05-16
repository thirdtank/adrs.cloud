class Admin::BasePage < AppPage
  def initialize(authenticated_account:)
    @authenticated_account = authenticated_account
  end
  def before_generate
    if !@authenticated_account.entitlements.admin?
      return http_status(404)
    end
  end
end
