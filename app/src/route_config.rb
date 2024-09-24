require "sinatra/base"

require "front_end/app_view_helpers"
require "front_end/components/app_component"
require "front_end/pages/app_page"
require "front_end/app_session"
require "back_end/db/app_data_model"
require "back_end/domain"
require "front_end/forms/app_form"
require "front_end/handlers/app_handler"

class AdrApp < Sinatra::Base

  include Brut::SinatraHelpers

  set :public_folder, Brut.container.public_root_dir

  use OmniAuth::Builder do
    provider :github, ENV.fetch("GITHUB_CLIENT_ID"), ENV.fetch("GITHUB_CLIENT_SECRET"), scope: "read:user,user:email"
  end


  before do

    app_session = Brut.container.session_class.new(rack_session: session)

    is_auth_callback         = request.path_info.match?(/^\/auth\//)
    is_root_path             = request.path_info == "/"
    is_public_dynamic_route  = request.path_info.match?(/^\/shared_adrs\//) && request.get?
    is_test_page             = request.path_info == "/end-to-end-tests"

    authenticated_account = AuthenticatedAccount.find(session_id: app_session.logged_in_account_id)

    requires_login = !is_auth_callback        &&
                     !is_root_path            &&
                     !is_public_dynamic_route &&
                     !is_test_page

    logged_in = false

    if authenticated_account && authenticated_account.active?
      Thread.current.thread_variable_get(:request_context)[:authenticated_account] = authenticated_account
      logged_in = true
      logger.info "Someone is logged in"
    end

    if requires_login
      logger.info "Login required"
      if !logged_in
        logger.info "No one is logged in"
        redirect to("/")
      end
    else
      logger.info "Login not required"
    end
  end

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

  page "/admin/home"
  page "/admin/accounts"
  page "/admin/accounts/:external_id"
  form "/admin/new_account"
  form "/admin/account_entitlements/:external_id"
  action "/admin/deactivated_accounts/:external_id"

end
