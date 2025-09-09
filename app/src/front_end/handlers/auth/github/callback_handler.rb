module Auth
  module Github
    class CallbackHandler < AppHandler
      def initialize(env:, flash:, session:)
        @env     = env
        @flash   = flash
        @session = session
      end

      def handle
        github_linked_account = GithubLinkedAccount.find_from_omniauth_hash(omniauth_hash: @env["omniauth.auth"])
        if github_linked_account.error?
          @flash.alert = github_linked_account.error_i18n_key
        elsif !github_linked_account.exists?
          @flash.alert = "auth.no_account"
        elsif github_linked_account.inactive?
          @flash.alert = "auth.no_account"
        else
          @session.login!(github_linked_account.session_id)
          return redirect_to(AdrsPage)
        end
        HomePage.new(flash: @flash)
      end
    end
  end
end
