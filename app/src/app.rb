require "omniauth"
require "sidekiq"
class App < Brut::Framework::App
  def id           = "adrsdotcloud"
  def organization = "third-tank"

  def initialize
    if Brut.container.project_env.development?
      ::OmniAuth.config.full_host = "http://0.0.0.0:6502"
    end
    Brut.container.override("session_class",AppSession)
    Brut.container.override("external_id_prefix","ad")
    Brut.container.override("fallback_host") do |project_env|
      if project_env.production?
        raise "this must be set"
      else
        URI("http://localhost:6502")
      end
    end
    Brut.container.store(
      "flush_spans_in_sidekiq?",
      "Boolean",
      "True if sidekiq jobs should flush all OTel spans after the job completes"
    ) do |project_env|
      if ENV["FLUSH_SPANS_IN_SIDEKIQ"] == "true"
        true
      elsif ENV["FLUSH_SPANS_IN_SIDEKIQ"] == "false"
        false
      else
        project_env.development?
      end
    end
  end

  def boot!
    Sidekiq.configure_server do |config|
      config.redis = {
        # Per https://devcenter.heroku.com/articles/connecting-heroku-redis#connecting-in-ruby
        ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE }
      }
      config.logger = SemanticLogger["Sidekiq:server"]
      if Brut.container.flush_spans_in_sidekiq?
        SemanticLogger[self.class].info("Sidekiq jobs will flush spans")
        config.server_middleware do |chain|
          if defined? OpenTelemetry::Instrumentation::Sidekiq::Middlewares::Server::TracerMiddleware
            chain.insert_before OpenTelemetry::Instrumentation::Sidekiq::Middlewares::Server::TracerMiddleware,
                                Brut::BackEnd::Sidekiq::Middlewares::Server::FlushSpans
          else
            SemanticLogger["Sidekiq:server"].warn("OpenTelemetry::Instrumentation::Sidekiq::Middlewares::Server::TracerMiddleware not defined")
          end
        end
      else
        SemanticLogger[self.class].info("Sidekiq jobs will not flush spans")
      end
    end

    Sidekiq.configure_client do |config|
      config.redis = {
        # Per https://devcenter.heroku.com/articles/connecting-heroku-redis#connecting-in-ruby
        ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE }
      }
      config.logger = SemanticLogger["Sidekiq:client"]
    end

  end

  middleware OmniAuth::Builder do
    provider :github, ENV.fetch("GITHUB_CLIENT_ID"), ENV.fetch("GITHUB_CLIENT_SECRET"), scope: "read:user,user:email"
  end

  before :SetSiteAnnouncementBeforeHook
  before :CheckLoginBeforeHook

  routes do
    action "/auth/developer"
    page "/developer-auth"

    page "/"

    path "/auth/developer/callback", method: :get
    path "/auth/github/callback", method: :get
    path "/logout", method: :get

    page "/adrs"

    page "/new_draft_adr"
    form "/new_draft_adr"

    page "/adrs/:external_id"

    page "/edit_draft_adr/:external_id"
    form "/edit_draft_adr/:external_id"

    form "/adr_tags/:external_id"

    form "/accepted_adrs/:external_id"
    action "/rejected_adrs/:external_id"
    action "/replaced_adrs/:existing_external_id"
    action "/refined_adrs/:existing_external_id"

    page "/shared_adrs/:shareable_id"
    action "/shared_adrs/:external_id"
    action "/private_adrs/:external_id"
    page "/account/:external_id"
    page "/new_project"
    form "/new_project"
    page "/edit_project/:external_id"
    form "/edit_project/:external_id"
    action "/archived_projects/:external_id"
    action "/downloads"
    path "/downloads/:external_id", method: :get
    path "/ready_downloads/:external_id", method: :get
    page "/admin/home"
    page "/admin/accounts"
    page "/admin/accounts/:external_id"
    form "/admin/new_account"
    form "/admin/account_entitlements/:external_id"
    action "/admin/deactivated_accounts/:external_id"
    page "/help"
  end
end

