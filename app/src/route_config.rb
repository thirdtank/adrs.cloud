require "sinatra/base"

require "front_end/app_view_helpers"
require "front_end/components/app_component"
require "front_end/pages/app_page"
require "back_end/data_models/app_data_model"
require "back_end/actions/app_action"
require "front_end/forms/app_form"

require "pp"

class AdrApp < Sinatra::Base

  enable :sessions
  set :session_secret, ENV.fetch("SESSION_SECRET")

  use Rack::Protection::AuthenticityToken

  set :public_folder, Brut.container.public_root_dir

  use OmniAuth::Builder do
    provider :github, ENV.fetch("GITHUB_CLIENT_ID"), ENV.fetch("GITHUB_CLIENT_SECRET"), scope: "read:user,user:email"
    provider :developer
  end

  include Brut::SinatraHelpers

  before do
    is_auth_callback         =  request.path_info.match?(/^\/auth\//)
    is_root                  =  request.path_info == "/"
    is_public_dynamic_route  =  request.path_info.match?(/^\/shareable_adrs\//)

    @account = DataModel::Account[external_id: session["user_id"]]
    Thread.current.thread_variable_get(:request_context)[:account] = @account

    logged_out = @account.nil?
    requires_login = !is_auth_callback && !is_root && !is_public_dynamic_route

    if requires_login
      logger.info "Login required"
      if logged_out
        logger.info "No one is logged in"
        redirect to("/")
      else
        logger.info "Someone is logged in so all good"
      end
    else
      logger.info "Login not required"
    end
  end

  get "/" do
    page Pages::Home.new
  end

  get "/logout" do
    session.delete("user_id")
    page Pages::Home.new(info: "You have logged out")
  end

  get "/auth/developer/callback" do
    action = Actions::DevOnlyAuth.new
    result = action.call(params[:email])
    if result.constraint_violations?
      page Pages::Home.new(check_result: result)
    else
      session["user_id"] = result[:account].external_id
      redirect to("/adrs")
    end
  end

  get "/auth/github/callback" do
    action = Actions::GitHubAuth.new
    result = action.call(env["omniauth.auth"])
    if result.constraint_violations?
      page Pages::Home.new(check_result: result)
    else
      session["user_id"] = result[:account].external_id
      redirect to("/adrs")
    end
  end

  page "/adrs"

  page "/new_draft_adr"
  form "/new_draft_adr"

  page "/adrs/:external_id"

  page "/edit_draft_adr/:external_id"
  form "/edit_draft_adr/:external_id"

  form "/adr_tags/:external_id"

  form "/accepted_adrs/:external_id"
  form "/rejected_adrs/:external_id"
  form "/replaced_adrs/:existing_external_id"
  form "/refined_adrs/:existing_external_id"

  page "/shareable_adrs/:shareable_id"

  post "/public_adrs" do
    Actions::Adrs::Public.new.make_public(external_id: params[:external_id], account: @account)
    redirect to("/adrs/#{params[:external_id]}")
  end
  post "/private_adrs" do
    Actions::Adrs::Public.new.make_private(external_id: params[:external_id], account: @account)
    redirect to("/adrs/#{params[:external_id]}")
  end
end
