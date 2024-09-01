class AppHandler < Brut::FrontEnd::Handler
end

require_relative "logout_handler"
require_relative "auth/developer/callback_handler"
require_relative "auth/github/callback_handler"
