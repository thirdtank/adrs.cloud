class AppAction < Brut::BackEnd::Action
end
module Actions
end
module Actions::Adrs
end

require_relative "login"
require_relative "sign_up"
require_relative "adrs/accept"
require_relative "adrs/reject"
require_relative "adrs/draft"
