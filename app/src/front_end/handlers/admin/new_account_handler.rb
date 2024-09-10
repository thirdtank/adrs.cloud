module Admin
  class NewAccountHandler < AppHandler
    def handle!(form:,flash:)
      result = GithubLinkedAccount.create(form:)
      case result
      in GithubLinkedAccount
        flash.notice = :account_created
        redirect_to(Admin::HomePage)
      else
        Admin::HomePage.new(new_account_form: result, flash:)
      end
    end
  end
end
