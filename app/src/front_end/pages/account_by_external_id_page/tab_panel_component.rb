class AccountByExternalIdPage::TabPanelComponent < AppComponent2
  attr_reader :tab_name
  def initialize(tab_name:, selected_name:)
    @tab_name = tab_name
    @selected = tab_name == selected_name
  end

  def self.page_name = "AccountByExternalIdPage"
  def page_name = "AccountByExternalIdPage"

  def selected? = @selected

  def view_template
    section(
      class: "pa-3",
      role: "tabpanel",
      tabindex: 0,
      hidden: !selected?,
      id: "#{tab_name }-panel"
    ) do
      h2(class: "f-4 ma-0") do
        t(page: [ "tabs", tab_name, "title" ])
      end
      p(class: "p f-2") do
        t(page: [ "tabs", tab_name, "intro" ])
      end
      yield
    end
  end
end
