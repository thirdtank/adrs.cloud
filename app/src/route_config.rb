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
    if request.path_info !~ /^\/auth\// && request.path_info != "/"
      @account = DataModel::Account[external_id: session["user_id"]]
      if !@account
        redirect to("/")
        return
      end
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
      adrs: Actions::Adrs::SearchByTag.new.call(account: @account, tag: tag)
    )
  end


  get "/adrs/new" do
    page Pages::Adrs::New.new(form: Forms::Adrs::Draft.new)
  end

  post "/adrs" do
    draft_adr = Forms::Adrs::Draft.new(params)
    result = process_form form: draft_adr,
                          action: Actions::Adrs::NewDraft.new,
                          account: @account
    case result
    in Forms::Adrs::Draft if result.invalid?
      page Pages::Adrs::New.new(form: draft_adr)
    in adr:
      flash[:notice] = :adr_created
      redirect to("/adrs/#{adr.external_id}/edit")
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
                          action: Actions::Adrs::EditDraft.new,
                          account: @account
    case result
    in Forms::Adrs::Draft if result.invalid?
      if request.xhr?
        [
          422,
          component(Components::Adrs::ErrorMessages.new(form: result)).to_s,
        ]
      else
        page Pages::Adrs::Edit.new(adr: result.server_side_context[:adr], form: draft_adr)
      end
    in adr:
      if request.xhr?
        200
      else
        flash[:notice] = :adr_updated
        redirect to("/adrs/#{adr.external_id}/edit")
      end
    end
  end

  post "/adr_tags" do
    adr_tags = Forms::Adrs::Tags.new(params)
    process_form form: adr_tags,
                 action: Actions::Adrs::UpdateTags.new,
                 account: @account
    redirect to("/adrs/#{adr_tags.external_id}")
  end

  post "/accepted_adrs" do
    form = Forms::Adrs::Draft.new(params)
    result = process_form form: form,
                          action: Actions::Adrs::Accept.new,
                          account: @account
    case result
    in Forms::Adrs::Draft if result.invalid?
      page Pages::Adrs::Edit.new(adr: result.server_side_context[:adr],
                                 error_message: "ADR could not be accepted",
                                 form: form)
    in adr:
      flash[:notice] = :adr_accepted
      redirect to("/adrs/#{adr.external_id}")
    end
  end

  post "/rejected_adrs" do
    draft_adr = Forms::Adrs::Draft.new(params)
    process_form form: draft_adr,
                 action: Actions::Adrs::Reject.new,
                 account: @account
    flash[:notice] = :adr_rejected
    redirect to("/adrs")
  end

  post "/replaced_adrs" do
    page Pages::Adrs::Replace.new(form: Forms::Adrs::Draft.new(params), account: @account)
  end

  post "/refined_adrs" do
    page Pages::Adrs::Refine.new(form: Forms::Adrs::Draft.new(params), account: @account)
  end
end
