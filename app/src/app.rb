require "omniauth"
class App < Brut::App
  def id           = "adrsdotcloud"
  def organization = "third-tank"

  def configure_only!
    super
    if Brut.container.project_env.development?
      ::OmniAuth.config.full_host = "http://0.0.0.0:6502"
    end
    Brut.container.override("session_class") do
      AppSession
    end
    if Brut.container.project_env.production?
      Sidekiq.configure_server do |config|
        config.redis = {
          url: ENV(ENV.fetch("REDIS_PROVIDER")),
          # Per https://devcenter.heroku.com/articles/connecting-heroku-redis#connecting-in-ruby
          ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE }
        }
      end

      Sidekiq.configure_client do |config|
        config.redis = {
          url: ENV(ENV.fetch("REDIS_PROVIDER")),
          # Per https://devcenter.heroku.com/articles/connecting-heroku-redis#connecting-in-ruby
          ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE }
        }
      end
    end

  end
end

