class AccountByExternalIdPage < AppPage
  attr_reader :authenticated_account, :selected_tab

  Tab = Data.define(:name,:icon)

  def initialize(authenticated_account:, external_id:, tab: nil)
    if authenticated_account.external_id != external_id
      raise "forbidden"
    end
    @selected_tab = tabs.detect { |t| t.name == tab } || tabs.first
    @authenticated_account = authenticated_account
  end

  def tabs
    [
      Tab.new(name: "adr-style", icon: "brush-pencil-icon"),
      Tab.new(name: "projects",  icon: "layer-icon"),
      Tab.new(name: "download",  icon: "database-download-icon"),
      Tab.new(name: "info",      icon: "speedometer-icon"),
    ]
  end

  def tab_panel(tab_name,&block)
    component(self.class::TabPanelComponent.new(tab_name: tab_name, selected_name: selected_tab.name),&block)
  end

end

require_relative "account_by_external_id_page/tab_panel_component"
