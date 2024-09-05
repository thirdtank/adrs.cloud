module Auth
  module Developer
    class CallbackHandler < AppHandler
      def handle!(email:, flash:, session:)
        action = Actions::DevOnlyAuth.new
        account = action.auth(email)
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
