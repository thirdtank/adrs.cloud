class AccountByExternalIdPage < AppPage
  attr_reader :authenticated_account, :selected_tab, :timezone_from_browser, :http_accept_language

  Tab = Data.define(:name,:icon)

  def initialize(authenticated_account:, external_id:, session:, tab: nil)
    if authenticated_account.external_id != external_id
      raise "forbidden"
    end
    @selected_tab          = tabs.detect { |t| t.name == tab } || tabs.first
    @authenticated_account = authenticated_account
    @timezone_from_browser = session.timezone_from_browser
    @http_accept_language  = session.http_accept_language
  end

  def tabs
    [
      Tab.new(name: "projects",  icon: "layer-icon"),
      Tab.new(name: "download",  icon: "database-download-icon"),
      Tab.new(name: "info",      icon: "speedometer-icon"),
    ]
  end
end
