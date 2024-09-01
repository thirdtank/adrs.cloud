module Auth
  module Github
    class CallbackHandler
      def handle!(env:, flash:, session:)
        action = Actions::GitHubAuth.new
        result = action.call(env["omniauth.auth"])
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
