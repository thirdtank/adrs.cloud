module Admin
  class DeactivatedAccountsWithExternalIdHandler < Admin::BaseHandler
    def handle(external_id:, flash:, authenticated_account:)
      github_linked_account = GithubLinkedAccount.find(external_id: external_id)
      if github_linked_account
        github_linked_account.deactivate!
      end
      flash.notice = :account_deactivated
      redirect_to(Admin::HomePage)
    end
  end
end
