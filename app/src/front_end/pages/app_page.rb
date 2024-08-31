class AppPage < Brut::FrontEnd::Page
  include AppViewHelpers
end
module Pages
  module Adrs
  end
end

require_relative "home"
require_relative "adrs/get"
#require_relative "adrs/replace"
#require_relative "adrs/refine"
require_relative "adrs/public_get"
require_relative "draft_adrs/new"

require_relative "adrs_page"
require_relative "adrs_by_external_id_page"
require_relative "new_draft_adr_page"
require_relative "edit_draft_adr_by_external_id_page"
require_relative "public_adrs_by_public_id_page"
