module Admin
  class AccountEntitlementsWithExternalIdHandler < AppHandler
    def handle!(form:, external_id:, flash:,authenticated_account:)
      if !authenticated_account.entitlements.admin?
        return http_status(404)
      end
      form = AccountEntitlements.find!(external_id:).update(form:)
      if form.constraint_violations?
        Admin::AccountsByExternalIdPage.new(form:,flash:,external_id:,authenticated_account:)
      else
        flash.notice = :entitlements_saved
        redirect_to(Admin::AccountsByExternalIdPage, external_id:,authenticated_account:)
      end
    end
  end
end
