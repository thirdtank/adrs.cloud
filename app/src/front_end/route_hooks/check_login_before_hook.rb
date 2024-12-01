class CheckLoginBeforeHook < Brut::FrontEnd::RouteHook
  def before(request_context:,session:,request:)
    is_brut_path             = request.path_info.match?(/^\/__brut\//)
    is_auth_callback         = request.path_info.match?(/^\/auth\//)
    is_root_path             = request.path_info == "/"
    is_public_dynamic_route  = request.path_info.match?(/^\/shared_adrs\//) && request.get?

    authenticated_account = AuthenticatedAccount.find(session_id: session.logged_in_account_id)

    requires_login = !is_brut_path            &&
                     !is_auth_callback        &&
                     !is_root_path            &&
                     !is_public_dynamic_route

    logged_in = false

    if authenticated_account && authenticated_account.active?
      request_context[:authenticated_account] = authenticated_account
      logged_in = true
    end

    if requires_login
      if !logged_in
        return redirect_to(HomePage)
      end
    end
    continue
  rescue => ex
    puts "#{Thread.current}: #{ex.message}"
    http_status(500)
  end
end
