class AppComponent < Brut::FrontEnd::Component
  include AppViewHelpers
end
module Components
end
require_relative "text_field"
require_relative "button"
require_relative "adrs"
require_relative "confirmation_dialog"
require_relative "markdown_string"
