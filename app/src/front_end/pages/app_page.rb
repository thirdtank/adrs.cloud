class AppPage < Brut::FrontEnd::Page
  include AppViewHelpers
end
module Admin
end
require_relative "home_page"
require_relative "help_page"
require_relative "adrs_page"
require_relative "developer_auth_page"
require_relative "adrs_by_external_id_page"
require_relative "new_draft_adr_page"
require_relative "edit_draft_adr_by_external_id_page"
require_relative "shared_adrs_by_shareable_id_page"
require_relative "account_by_external_id_page"
require_relative "new_project_page"
require_relative "edit_project_by_external_id_page"
require_relative "admin/home_page"
require_relative "admin/accounts_page"
require_relative "admin/accounts_by_external_id_page"
