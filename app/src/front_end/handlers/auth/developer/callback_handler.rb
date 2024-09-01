module Auth
  module Developer
    class CallbackHandler
      def handle!(email:, flash:, session:)
        action = Actions::DevOnlyAuth.new
        result = action.call(email)
        if result.constraint_violations?
          Brut::FrontEnd::FormProcessingResponse.render_page(HomePage.new(flash:))
        else
          session["user_id"] = result[:account].external_id
          Brut::FrontEnd::FormProcessingResponse.redirect_to(Brut.container.routing.for(AdrsPage))
        end
      end
    end
  end
end
