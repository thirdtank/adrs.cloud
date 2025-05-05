class Admin::BaseHandler < AppHandler
  def before_handle
    if !@authenticated_account.entitlements.admin?
      return http_status(404)
    end
  end
end
