class AdrsPage::TabPanelComponent < AppComponent
  attr_reader :tab, :columns, :adrs
  def initialize(adrs:, tab:, columns:, selected: false, action: :use_block)
    @adrs         =   adrs
    @tab          =   tab
    @columns      =   columns
    @action       =   action
    @selected     = !!selected
  end

  def custom_action?
    @action == :use_block
  end

  def selected? = @selected

  def action_block(adr)
    if @yielded_block
      Brut::FrontEnd::Templates::HTMLSafeString.new(@yielded_block.(adr:))
    end
  end

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
      Brut::FrontEnd::Templates::HTMLSafeString.new(%{<span class='ws-nowrap'>
  #{format_timestamp(value, format: :date)}
</span>})
    elsif column == :title
      component(AdrsPage::AdrTitleComponent.new(adr:))
    elsif column == :replaced_by
      Brut::FrontEnd::Templates::HTMLSafeString.new(
        "<span class=\"ws-nowrap\">#{adr.replaced_by_adr.title}</span>"
      )
    else
      adr.send(column)
    end
  end
end
