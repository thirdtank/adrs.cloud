require "brut"
require "sinatra/base"
require "sinatra/namespace"

DB = Sequel.connect(ENV.fetch("DATABASE_URL"))
Sequel::Model.db = DB

at_exit do
  DB.disconnect
end

require_relative "view/components/app_component"
require_relative "view/pages/app_page"
require_relative "data_models/app_data_model"
require_relative "actions/app_action"
require_relative "view/form_submissions/app_form_submission"

class SignUp < Brut::Form
  input :email
  input :password, minlength: 8
  input :password_confirmation, type: "password"
end

class AdrApp < Sinatra::Base

  register Sinatra::Namespace

  enable :sessions
  set :session_secret, ENV.fetch("SESSION_SECRET")
  include Brut::SinatraHelpers

  before do
    if request.path_info !~ /^\/auth\// && request.path_info != "/"
      @account = DataModel::Account[external_id: session["user_id"]]
      if !@account
        redirect to("/auth/login")
        return
      end
    end
  end

  get "/" do
    redirect to("/static/index.html")
  end

  namespace "/auth" do

    get "/login" do
      page Pages::Login.new(content: FormSubmissions::Login.new)
    end

    post "/login" do
      login = FormSubmissions::Login.new(params)
      result = process_form form_submission: login,
                            action: Actions::Login.new
      case result
      in errors:
        page Pages::Login.new(content: login, errors: errors)
      in DataModel::Account
        session["user_id"] = result.external_id
        redirect to("/adrs")
      end
    end

    get "/sign-up" do
      page Pages::SignUp.new(content: SignUp.new)
    end

    post "/sign-up" do
      sign_up = SignUp.new(params)
      if sign_up.valid?
        if sign_up.password != sign_up.password_confirmation
          sign_up["password_confirmation"].set_custom_validity("must match password")
        end
      end
      if sign_up.valid?
        raise "WELP"
      else
        page Pages::SignUp.new(content: sign_up)
      end
      #case result
      #in errors:
      #  page Pages::SignUp.new(content: sign_up, errors: errors)
      #in DataModel::Account
      #  session["user_id"] = result.external_id
      #  redirect to("/adrs")
      #end
    end

    get "/logout" do
      session["user_id"] = nil
      redirect to("/auth/login")
    end
  end

  get "/adrs" do
    page Pages::Adrs.new(content: @account.adrs)
  end

  get "/adrs/new" do
    page Pages::Adrs::New.new(content: FormSubmissions::Adrs::Draft.new)
  end

  get "/adrs/:id" do
    page Pages::Adrs::Get.new(content: DataModel::Adr[account_id: @account.id, external_id: params[:id]])
  end

  get "/adrs/:id/edit" do
    page Pages::Adrs::Edit.new(content: FormSubmissions::Adrs::Draft.from_adr(DataModel::Adr[account_id: @account.id, external_id: params[:id]]))
  end

  post "/adrs" do
    draft_adr = FormSubmissions::Adrs::Draft.new(params)
    result = process_form form_submission: draft_adr,
                          action: Actions::Adrs::Draft.new,
                          account: @account
    case result
    in errors:
      page Pages::Adrs::New.new(content: draft_adr, errors: errors)
    else
      redirect to("/adrs")
    end
  end

  post "/accepted_adrs" do
    accepted_adr = FormSubmissions::Adrs::Accepted.new(params)
    result = process_form form_submission: accepted_adr,
                          action: Actions::Adrs::Accept.new,
                          account: @account
    case result
    in errors:
      page Pages::Adrs::Edit.new(
        content: FormSubmissions::Adrs::Draft.from_adr(Adr[account_id: @account.id, external_id: accepted_adr.external_id]),
        errors: errors
      )
    else
      redirect to("/adrs/#{accepted_adr.external_id}")
    end
  end
  post "/rejected_adrs" do
    rejected_adr = FormSubmissions::Adrs::Rejected.new(params)
    process_form form_submission: rejected_adr,
                 action: Actions::Adrs::Reject.new,
                 account: @account
    redirect to("/adrs")
  end
end
