module Admin
  class NewAccountHandler < Admin::BaseHandler
    def handle(form:,flash:,authenticated_account:)
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
