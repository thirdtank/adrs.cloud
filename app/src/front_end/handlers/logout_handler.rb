class LogoutHandler < AppHandler
  def initialize(flash:, session:)
    @flash = flash
    @session = session
  end

  def handle
    @session.logout!

    @flash.notice = "auth.logged_out"
    redirect_to(HomePage)
  end
end
