require "omniauth"
class App < Brut::App
  def id           = "adrpg"
  def organization = "third-tank"

  def configure_only!
    super
    if Brut.container.project_env.development?
      ::OmniAuth.config.full_host = "http://0.0.0.0:6502"
    end
    Brut.container.override("session_class") do
      AppSession
    end

  end
end

