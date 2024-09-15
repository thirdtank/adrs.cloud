module Auth
  module Developer
    class CallbackHandler < AppHandler
      def handle!(email:, flash:, session:)
        dev_only_account = DeveloperOnlyAccount.search(email:)
        if dev_only_account.nil?
          flash.alert = "auth.no_account"
          HomePage.new(flash:)
        else
          session.login!(dev_only_account.session_id)
          redirect_to(AdrsPage)
        end
      end
    end
  end
end
