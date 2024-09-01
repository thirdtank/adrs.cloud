class LogoutHandler < AppHandler
  def handle!(flash:, session:)
    session.delete("user_id")

    flash[:notice] = "actions.auth.logged_out"
    redirect_to(HomePage)
  end
end
