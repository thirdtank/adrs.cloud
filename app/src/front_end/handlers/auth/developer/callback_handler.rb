module Auth
  module Developer
    class CallbackHandler < AppHandler
      def handle!(email:, flash:, session:)
        dev_only_account = DeveloperOnlyAccount.find(email:)
        if dev_only_account.exists?
          session["user_id"] = dev_only_account.session_id
          redirect_to(AdrsPage)
        else
          flash[:error] = "auth.no_account"
          HomePage.new(flash:)
        end
      end
    end
  end
end
