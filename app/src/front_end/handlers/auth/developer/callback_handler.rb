module Auth
  module Developer
    class CallbackHandler < AppHandler
      def initialize(email:, flash:, session:)
        @email = email
        @flash = flash
        @session = session
      end

      def handle
        dev_only_account = DeveloperOnlyAccount.find(email: @email)
        if dev_only_account.nil?
          @flash.alert = "auth.no_account"
          HomePage.new(flash: @flash)
        else
          @session.login!(dev_only_account.session_id)
          redirect_to(AdrsPage)
        end
      end
    end
  end
end
