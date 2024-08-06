require "sinatra/base"
require "sinatra/namespace"

require "front_end/app_view_helpers"
require "front_end/components/app_component"
require "front_end/pages/app_page"
require "back_end/data_models/app_data_model"
require "back_end/actions/app_action"
require "front_end/forms/app_form"

class AdrApp < Sinatra::Base

  register Sinatra::Namespace

  enable :sessions
  set :session_secret, ENV.fetch("SESSION_SECRET")

  use Rack::Protection::AuthenticityToken

  set :public_folder, Brut.container.public_root_dir

  use OmniAuth::Strategies::Developer

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

  get "/auth/developer/callback" do
    login = Forms::Login.new(email: params[:email], password: "foobardoesnotmatter")
    result = process_form form: login,
      action: Actions::Login.new
    case result
    in Forms::Login if result.invalid?
      redirect to("/")
    in account:
      session["user_id"] = account.external_id
      redirect to("/adrs")
    end
  end

  namespace "/athn" do

    get "/login" do

      SemanticLogger["get /login"].info("Getting login page")
      page Pages::Login.new(content: Forms::Login.new)
    end

    post "/login" do
      login = Forms::Login.new(params)
      result = process_form form: login,
                            action: Actions::Login.new
      case result
      in Forms::Login if result.invalid?
        page Pages::Login.new(content: login)
      in account:
        session["user_id"] = account.external_id
        redirect to("/adrs")
      end
    end

    get "/sign-up" do
      page Pages::SignUp.new(content: Forms::SignUp.new)
    end

    post "/sign-up" do
      sign_up = Forms::SignUp.new(params)
      result = process_form form: sign_up,
                            action: Actions::SignUp.new
      case result
      in Forms::SignUp if result.invalid?
        page Pages::SignUp.new(content: sign_up)
      in account:
        session["user_id"] = account.external_id
        redirect to("/adrs")
      end
    end

    get "/logout" do
      session["user_id"] = nil
      redirect to("/athn/login")
    end
  end

  get "/adrs" do
    page Pages::Adrs.new(content: @account.adrs)
  end

  get "/adrs/new" do
    page Pages::Adrs::New.new(content: Forms::Adrs::Draft.new)
  end

  get "/adrs/:id" do
    page Pages::Adrs::Get.new(content: DataModel::Adr[account_id: @account.id, external_id: params[:id]])
  end

  get "/adrs/:id/edit" do
    page Pages::Adrs::Edit.new(adr: DataModel::Adr[account_id: @account.id, external_id: params[:id]])
  end

  post "/adrs" do
    draft_adr = Forms::Adrs::Draft.new(params)
    result = process_form form: draft_adr,
                          action: Actions::Adrs::Draft.new,
                          account: @account
    case result
    in Forms::Adrs::Draft if result.invalid?
      page Pages::Adrs::New.new(content: draft_adr)
    else
      redirect to("/adrs")
    end
  end

  post "/accepted_adrs" do
    form = Forms::Adrs::Draft.new(params)
    result = process_form form: form,
                          action: Actions::Adrs::Accept.new,
                          account: @account
    case result
    in Forms::Adrs::Draft if result.invalid?
      page Pages::Adrs::Edit.new(adr: DataModel::Adr[account_id: @account.id, external_id: form.external_id],
                                 error_message: "ADR could not be accepted",
                                 form: form)
    in adr:
      redirect to("/adrs/#{adr.external_id}")
    end
  end

  post "/rejected_adrs" do
    draft_adr = Forms::Adrs::Draft.new(params)
    process_form form: draft_adr,
                 action: Actions::Adrs::Reject.new,
                 account: @account
    redirect to("/adrs")
  end

  post "/replaced_adrs" do
    page Pages::Adrs::Replace.new(form: Forms::Adrs::Draft.new(params), account: @account)
  end

  post "/refined_adrs" do
    page Pages::Adrs::Refine.new(form: Forms::Adrs::Draft.new(params), account: @account)
  end
end
