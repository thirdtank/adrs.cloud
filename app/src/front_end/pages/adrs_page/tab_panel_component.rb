class AdrsPage::TabPanelComponent < AppComponent
  attr_reader :tab, :columns, :adrs
  def initialize(adrs:, tab:, columns:, selected: false, action:)
    @adrs         =   adrs
    @tab          =   tab
    @columns      =   columns
    @action       =   action
    @selected     = !!selected
  end

  def selected? = @selected

  def action_routing(adr)
    if @action == :edit
      EditDraftAdrByExternalIdPage.routing(external_id: adr.external_id)
    elsif @action == :view
      AdrsByExternalIdPage.routing(external_id: adr.external_id)
    end
  end

  def action_name
    @action
  end

  def column_value(adr,column)
    if column.to_s =~ /_at$/
      value = adr.send(column)
      html_tag(:span, class: "ws-nowrap") do
        timestamp(value, format: :date)
      end
    elsif column == :title
      component(AdrsPage::AdrTitleComponent.new(adr:))
    else
      adr.send(column)
    end
  end
end
