module Admin
  class AccountEntitlementsWithExternalIdHandler < AppHandler
    def handle!(form:, external_id:, flash:)
      form = AccountEntitlements.find(external_id:).update(form:)
      if form.constraint_violations?
        Admin::AccountsByExternalIdPage.new(form:,flash:)
      else
        flash.notice = :entitlements_saved
        redirect_to(Admin::AccountsByExternalIdPage, external_id:)
      end
    end
  end
end
