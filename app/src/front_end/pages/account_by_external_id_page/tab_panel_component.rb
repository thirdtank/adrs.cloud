class AccountByExternalIdPage::TabPanelComponent < AppComponent
  attr_reader :tab_name
  def initialize(tab_name:, selected_name:)
    @tab_name = tab_name
    @selected = tab_name == selected_name
  end

  def selected? = @selected

  def content
    render_yielded_block
  end
end
