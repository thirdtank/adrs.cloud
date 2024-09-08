module Auth
  module Github
    class CallbackHandler < AppHandler
      def handle!(env:, flash:, session:)
        github_linked_account = GithubLinkedAccount.find(omniauth_hash: env["omniauth.auth"])
        if github_linked_account.exists?
          session.login!(github_linked_account.session_id)
          redirect_to(AdrsPage)
        else
          flash.alert = "auth.no_account"
          HomePage.new(flash:)
        end
      end
    end
  end
end
