require_relative "app/bootstrap"
bootstrap = Bootstrap.new.bootstrap!
require "sidekiq/web"

app = Rack::Builder.app do
  use Rack::Session::Cookie,
    key: "rack.session",
    path: "/",
    expire_after: 31_536_000,
    same_site: :lax, # this allows links from other domains to send our cookies to us,
                     # but only if such links are direct/obvious to the user.
    secret: ENV.fetch("SESSION_SECRET")

  map "/sidekiq" do
    use Rack::Auth::Basic, "Sidekiq" do |username, password|
      [username, password] == [ENV.fetch("SIDEKIQ_BASIC_AUTH_USER"), ENV.fetch("SIDEKIQ_BASIC_AUTH_PASSWORD")]
    end
    run Sidekiq::Web.new
  end
  run bootstrap.rack_app
end
run app
