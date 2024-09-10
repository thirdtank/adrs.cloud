module Admin
  class DeactivatedAccountsWithExternalIdHandler < AppHandler
    def handle!(external_id:, flash:)
      github_linked_account = GithubLinkedAccount.find(external_id: external_id)
      github_linked_account.deactivate!
      flash.notice = :account_deactivated
      redirect_to(Admin::HomePage)
    end
  end
end
