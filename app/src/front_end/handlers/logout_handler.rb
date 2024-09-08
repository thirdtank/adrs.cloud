class LogoutHandler < AppHandler
  def handle!(flash:, session:)
    session.logout!

    flash[:notice] = "auth.logged_out"
    redirect_to(HomePage)
  end
end
