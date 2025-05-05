module Auth
  module Github
    class CallbackHandler < AppHandler
      def initialize(env:, flash:, session:)
        @env = env
        @flash = flash
        @session = session
      end

      def handle
        github_linked_account = GithubLinkedAccount.find_from_omniauth_hash(omniauth_hash: @env["omniauth.auth"])
        if github_linked_account && github_linked_account.error?
          @flash.alert = github_linked_account.error_i18n_key
          HomePage.new(flash: @flash)
        elsif github_linked_account.nil? || !github_linked_account.active?
          @flash.alert = "auth.no_account"
          HomePage.new(flash: @flash)
        else
          @session.login!(github_linked_account.session_id)
          redirect_to(AdrsPage)
        end
      end
    end
  end
end
