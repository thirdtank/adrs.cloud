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
    is_auth_callback         =  request.path_info.match?(/^\/auth\//)
    is_root                  =  request.path_info == "/"
    is_public_dynamic_route  =  request.path_info.match?(/^\/public_adrs\//)

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

  #get "/adrs" do
  #  page Pages::Adrs.new(adrs: @account.adrs, info_message: flash[:notice])
  #end

  #get "/adr_tags/:tag" do
  #  tag = params[:tag]
  #  page Pages::AdrsForTag.new(
  #    tag: tag,
  #    adrs: Actions::Adrs::Search.new.by_tag(account: @account, tag: tag)
  #  )
  #end

  pagex "/draft_adrs/new", form_class: Forms::Adrs::Draft
  #get "/adrs/new" do
  #  page Pages::Adrs::New.new(form: Forms::Adrs::Draft.new)
  #end

  post "/draft_adrs" do
    draft_adr = Forms::Adrs::Draft.new(params)
    result = process_form form: draft_adr,
                          action: Actions::Adrs::SaveDraft.new,
                          action_method: :save_new,
                          account: @account
    if result.constraint_violations?
      page Pages::Adrs::New.new(form: result.form)
    else
      flash[:notice] = "actions.adrs.created"
      redirect to("/adrs/#{result.action_return_value.external_id}/edit")
    end
  end

  # Form submission:
  #
  # 1 - create a Form instance with only those params desired
  # 2 - re-validate client-side validations
  # 3 - Process the form with back-end class
  # 4 - If there are constraint violations, render a page
  # 5 - If not, redirect or render another page
  #
  # Of note: rendering a page instead of redirect can create confusion - can this be avoided?
  #
  # What if the Form did it all? Or did more?
  #
  # form = form_class.new(params)
  # form.process!
  #
  # if form.constraint_violations?
  #   # XXX
  # else
  #   # YYY
  # end
  #
  # How would redirect-after-post work for errors?
  #
  # - violations are just an array of fields/values/context
  # - serialize those in a short-lived cookie and/or flash-type structure

  page "/adrs/:external_id"

  #get "/adrs/:external_id" do
  #  page Pages::Adrs::Get.new(
  #    adr: DataModel::Adr[account_id: @account.id, external_id: params[:external_id]],
  #    info_message: flash[:notice]
  #  )
  #end

  page "/adrs/edit/:external_id"

  #get "/adrs/:external_id/edit" do
  #  page Pages::Adrs::Edit.new(
  #    adr: DataModel::Adr[account_id: @account.id, external_id: params[:external_id]],
  #    updated_message: "actions.adrs.updated",
  #  )
  #end

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
        flash[:notice] = "actions.adrs.updated"
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
                                 error_message: "pages.adrs.edit.adr_cannot_be_accepted",
                                 form: result.form)
    else
      flash[:notice] = "actions.adrs.accepted"
      redirect to("/adrs/#{result.action_return_value.external_id}")
    end
  end

  post "/rejected_adrs" do
    draft_adr = Forms::Adrs::Draft.new(params)
    process_form form: draft_adr,
                 action: Actions::Adrs::Reject.new,
                 action_method: :reject,
                 account: @account
    flash[:notice] = "actions.adrs.rejected"
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

  page "/public_adrs/:public_id"
  #get "/p/adrs/:id" do
  #  adr = DataModel::Adr[public_id: params[:id]]
  #  page Pages::Adrs::PublicGet.new(adr: adr, account: @account)
  #end

  post "/public_adrs" do
    Actions::Adrs::Public.new.make_public(external_id: params[:external_id], account: @account)
    redirect to("/adrs/#{params[:external_id]}")
  end
  post "/private_adrs" do
    Actions::Adrs::Public.new.make_private(external_id: params[:external_id], account: @account)
    redirect to("/adrs/#{params[:external_id]}")
  end
end
