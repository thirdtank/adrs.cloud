class LogoutHandler < AppHandler
  def handle!(flash:, session:)
    session.delete("user_id")

    flash[:notice] = "actions.auth.logged_out"
    Brut::FrontEnd::FormProcessingResponse.redirect_to(Brut.container.routing.for(HomePage))
  end
end
