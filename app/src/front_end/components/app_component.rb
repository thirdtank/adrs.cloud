class AppComponent < Brut::FrontEnd::Component
  include AppViewHelpers
end
require_relative "text_field_component"
require_relative "button_component"
require_relative "adrs"
require_relative "confirmation_dialog_component"
require_relative "markdown_string_component"

module Adrs
end

require_relative "adrs/form_component"
require_relative "adrs/tag_component"
require_relative "adrs/textarea_component"
require_relative "adrs/get_refinements_component"
require_relative "adrs/error_messages_component"
