class AppPage < Brut::FrontEnd::Page
  include AppViewHelpers
end
module Pages
end

require_relative "login"
require_relative "sign_up"
require_relative "home"
require_relative "adrs"
require_relative "adrs/new"
require_relative "adrs/get"
require_relative "adrs/edit"
require_relative "adrs/replace"
require_relative "adrs/refine"
