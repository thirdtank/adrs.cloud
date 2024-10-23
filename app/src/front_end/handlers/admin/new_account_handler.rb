module Admin
  class NewAccountHandler < AppHandler
    def handle!(form:,flash:,authenticated_account:)
      if !authenticated_account.entitlements.admin?
        return http_status(404)
      end
      result = GithubLinkedAccount.create(form:)
      case result
      in GithubLinkedAccount
        flash.notice = :account_created
        redirect_to(Admin::HomePage)
      else
        Admin::HomePage.new(new_account_form: result, flash:,authenticated_account:)
      end
    end
  end
end
