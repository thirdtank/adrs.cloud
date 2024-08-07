require "omniauth"
class App < Brut::App
  def id           = "adrpg"
  def organization = "third-tank"

  def configure_only!
    super()
    if Brut.container.environment.development?
      ::OmniAuth.config.full_host = "http://0.0.0.0:6502"
    end
  end
end
