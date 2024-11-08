require "omniauth"
require "sidekiq"
class App < Brut::App
  def id           = "adrsdotcloud"
  def organization = "third-tank"

  def configure!
    if Brut.container.project_env.development?
      ::OmniAuth.config.full_host = "http://0.0.0.0:6502"
    end
    Brut.container.override("session_class",AppSession)
    Brut.container.override("external_id_prefix","ad")
  end

  def boot!
    Sidekiq.configure_server do |config|
      config.redis = {
        # Per https://devcenter.heroku.com/articles/connecting-heroku-redis#connecting-in-ruby
        ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE }
      }
      config.logger = SemanticLogger["Sidekiq:server"]
    end

    Sidekiq.configure_client do |config|
      config.redis = {
        # Per https://devcenter.heroku.com/articles/connecting-heroku-redis#connecting-in-ruby
        ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE }
      }
      config.logger = SemanticLogger["Sidekiq:client"]
    end

  end
end

