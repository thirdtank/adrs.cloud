module Admin
  class DeactivatedAccountsWithExternalIdHandler < AppHandler
    def handle!(external_id:, flash:, authenticated_account:)
      if !authenticated_account.entitlements.admin?
        return http_status(404)
      end
      github_linked_account = GithubLinkedAccount.find(external_id: external_id)
      if github_linked_account
        github_linked_account.deactivate!
      end
      flash.notice = :account_deactivated
      redirect_to(Admin::HomePage)
    end
  end
end
