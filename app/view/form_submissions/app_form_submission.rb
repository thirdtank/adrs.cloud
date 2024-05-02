module FormSubmissions
  module Adrs
  end
end
class AppFormSubmission < Brut::FormSubmission
end
require_relative "login"
require_relative "sign_up"
require_relative "adrs/accepted"
require_relative "adrs/rejected"
require_relative "adrs/draft"
