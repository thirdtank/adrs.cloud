module Admin
  class NewAccountHandler < Admin::BaseHandler
    def initialize(form:, flash:, authenticated_account:)
      @form = form
      @flash = flash
      @authenticated_account = authenticated_account
    end

    def handle
      result = GithubLinkedAccount.create(form: @form)
      case result
      in GithubLinkedAccount
        @flash.notice = :account_created
        redirect_to(Admin::HomePage)
      else
        Admin::HomePage.new(new_account_form: result, flash: @flash, authenticated_account: @authenticated_account)
      end
    end
  end
end
