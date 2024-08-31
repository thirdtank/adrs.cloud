class AppForm < Brut::FrontEnd::Form
end

module Forms
end
module Forms::Adrs
end
require_relative "adrs/draft"
require_relative "adrs/tags"
require_relative "new_draft_adr_form"
require_relative "edit_draft_adr_with_external_id_form"
