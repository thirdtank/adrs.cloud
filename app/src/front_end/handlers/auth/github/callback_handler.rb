module Auth
  module Github
    class CallbackHandler < AppHandler
      def handle!(env:, flash:, session:)
        action = Actions::GitHubAuth.new
        account = action.auth(env["omniauth.auth"])
        if account.nil?
          flash[:error] = "auth.no_account"
          HomePage.new(flash:)
        else
          session["user_id"] = account.external_id
          redirect_to(AdrsPage)
        end
      end
    end
  end
end
