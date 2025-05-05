module Admin
  class AccountEntitlementsWithExternalIdHandler < Admin::BaseHandler
    def initialize(form:, external_id:, flash:, authenticated_account:)
      @form = form
      @external_id = external_id
      @flash = flash
      @authenticated_account = authenticated_account
    end

    def handle
      form = AccountEntitlements.find!(external_id: @external_id).update(form: @form)
      if form.constraint_violations?
        Admin::AccountsByExternalIdPage.new(form: form, flash: @flash, external_id: @external_id, authenticated_account: @authenticated_account)
      else
        @flash.notice = :entitlements_saved
        redirect_to(Admin::AccountsByExternalIdPage, external_id: @external_id, authenticated_account: @authenticated_account)
      end
    end
  end
end
