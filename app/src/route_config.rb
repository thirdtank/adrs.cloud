require "sinatra/base"
require "sinatra/namespace"

require "front_end/app_view_helpers"
require "front_end/components/app_component"
require "front_end/pages/app_page"
require "back_end/data_models/app_data_model"
require "back_end/actions/app_action"
require "front_end/forms/app_form"

require "pp"

class AdrApp < Sinatra::Base

  register Sinatra::Namespace

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
    is_auth_callback         =  request.path_info =~ /^\/auth\//
    is_root                  =  request.path_info == "/"
    is_public_dynamic_route  =  request.path_info =~ /^\/p\//

    @account = DataModel::Account[external_id: session["user_id"]]

    logged_out = @account.nil?
    allowed_when_logged_out = is_auth_callback || is_root || is_public_dynamic_route

    if logged_out && !allowed_when_logged_out
      redirect to("/")
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
    case result
    in account:
      session["user_id"] = account.external_id
      redirect to("/adrs")
    else
      page Pages::Home.new(check_result: result)
    end
  end

  get "/auth/github/callback" do
    action = Actions::GitHubAuth.new
    result = action.call(env["omniauth.auth"])
    case result
    in account:
      session["user_id"] = account.external_id
      redirect to("/adrs")
    else
      page Pages::Home.new(check_result: result)
    end
  end

  get "/adrs" do
    page Pages::Adrs.new(adrs: @account.adrs, info_message: flash[:notice])
  end

  get "/adr_tags/:tag" do
    tag = params[:tag]
    page Pages::AdrsForTag.new(
      tag: tag,
      adrs: Actions::Adrs::Search.new.by_tag(account: @account, tag: tag)
    )
  end


  get "/adrs/new" do
    page Pages::Adrs::New.new(form: Forms::Adrs::Draft.new)
  end

  post "/adrs" do
    draft_adr = Forms::Adrs::Draft.new(params)
    result = process_form form: draft_adr,
                          action: Actions::Adrs::SaveDraft.new,
                          action_method: :save_new,
                          account: @account
    if result.constraint_violations?
      page Pages::Adrs::New.new(form: result.form)
    else
      flash[:notice] = :adr_created
      redirect to("/adrs/#{result.action_return_value.external_id}/edit")
    end
  end

  get "/adrs/:external_id" do
    page Pages::Adrs::Get.new(
      adr: DataModel::Adr[account_id: @account.id, external_id: params[:external_id]],
      info_message: flash[:notice]
    )
  end

  get "/adrs/:external_id/edit" do
    page Pages::Adrs::Edit.new(
      adr: DataModel::Adr[account_id: @account.id, external_id: params[:external_id]],
      updated_message: flash[:notice]
    )
  end

  post "/adrs/:external_id" do
    draft_adr = Forms::Adrs::Draft.new(params)
    result = process_form form: draft_adr,
                          action: Actions::Adrs::SaveDraft.new,
                          action_method: :update,
                          account: @account
    if result.constraint_violations?
      if request.xhr?
        [
          422,
          component(Components::Adrs::ErrorMessages.new(form: result.form)).to_s,
        ]
      else
        page Pages::Adrs::Edit.new(adr: result[:adr], form: result.form)
      end
    else

      if request.xhr?
        200
      else
        flash[:notice] = :adr_updated
        redirect to("/adrs/#{result.action_return_value.external_id}/edit")
      end
    end
  end

  post "/adr_tags" do
    adr_tags = Forms::Adrs::Tags.new(params)
    process_form form: adr_tags,
                 action: Actions::Adrs::UpdateTags.new,
                 action_method: :update,
                 account: @account
    redirect to("/adrs/#{adr_tags.external_id}")
  end

  post "/accepted_adrs" do
    form = Forms::Adrs::Draft.new(params)
    result = process_form form: form,
                          action: Actions::Adrs::Accept.new,
                          action_method: :accept,
                          account: @account
    if result.constraint_violations?
      page Pages::Adrs::Edit.new(adr: result[:adr],
                                 error_message: "ADR could not be accepted",
                                 form: result.form)
    else
      flash[:notice] = :adr_accepted
      redirect to("/adrs/#{result.action_return_value.external_id}")
    end
  end

  post "/rejected_adrs" do
    draft_adr = Forms::Adrs::Draft.new(params)
    process_form form: draft_adr,
                 action: Actions::Adrs::Reject.new,
                 action_method: :reject,
                 account: @account
    flash[:notice] = :adr_rejected
    redirect to("/adrs")
  end

  post "/replaced_adrs" do
    form = Forms::Adrs::Draft.new(
      replaced_adr_external_id: params[:external_id]
    )
    page Pages::Adrs::Replace.new(form: form, account: @account)
  end

  post "/refined_adrs" do
    form = Forms::Adrs::Draft.new(
      refines_adr_external_id: params[:external_id]
    )
    page Pages::Adrs::Refine.new(form: form, account: @account)
  end

  get "/p/adrs/:id" do
    adr = DataModel::Adr[public_id: params[:id]]
    page Pages::Adrs::PublicGet.new(adr: adr, account: @account)
  end

  post "/public_adrs" do
    Actions::Adrs::Public.new.make_public(external_id: params[:external_id], account: @account)
    redirect to("/adrs/#{params[:external_id]}")
  end
  post "/private_adrs" do
    Actions::Adrs::Public.new.make_private(external_id: params[:external_id], account: @account)
    redirect to("/adrs/#{params[:external_id]}")
  end
end
