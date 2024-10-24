class Admin::BaseHandler < AppHandler
  def before_handle(authenticated_account:)
    if !authenticated_account.entitlements.admin?
      return http_status(404)
    end
  end
end
