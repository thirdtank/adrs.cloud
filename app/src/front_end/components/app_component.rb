class AppComponent < Brut::FrontEnd::Component
  include AppViewHelpers
end
module Components
end
require_relative "text_field_component"
require_relative "button_component"
require_relative "adrs"
require_relative "confirmation_dialog_component"
require_relative "markdown_string_component"
