class AdrsPage::TabPanelComponent < AppComponent

  attr_reader :tab, :columns, :adrs, :tag, :project

  def initialize(adrs:, tab:, columns:, selected: false, action:, tag:, project:)
    @adrs         =   adrs
    @tab          =   tab
    @columns      =   columns
    @action       =   action
    @selected     = !!selected
    @tag          =   tag
    @project      =   project
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
      span(class: "ws-nowrap gray-400 fw-5") {
        time_tag(timestamp: value, format: :date)
      }
    elsif column == :title
      render(AdrsPage::AdrTitleComponent.new(adr:))
    elsif column == :project
      span(class: "ws-nowrap b") { adr.project.name }
    else
      adr.send(column)
    end
  end

  def view_template
    section(
      role: "tabpanel",
      tabindex: 0,
      id: "#{ tab }-panel",
      class: "w-100" ,
      hidden: !selected?
    ) do
    h2(class:"ph-3 f-5 b ma-0 mt-4") do
      div(class:"flex items-center gap-2") do
        span { t(page: tab) }
        if !tag.nil?
          render(Adrs::TagComponent.new(tag: tag, link: false))
        end
      end
      if !project.nil?
        span(class:"f-1") { "Project:" }
        span(class:"i f-1 fw-3") { project.name }
      end
    end
  if adrs.any?
    table(class:"collapse ma-3 striped") do
      caption(class:"sr-only") { t(page: "captions.#{tab}") }
      thead do
        tr do
          columns.each do |column|
            th(class:"tl ws-nowrap f-1 ttu b pa-2 bb bc-gray-600") do
              t(page: "columns.#{column}")
            end
          end
          th(class:"tl ws-nowrap f-1 ttu b pa-2 bb bc-gray-600") do
            span(class: "sr-only") { t(page: "columns.actions") }
          end
        end 
      end 
      tbody do
        adrs.each do |adr|
          tr(title: adr.title, id: adr.external_id) do
            columns.each_with_index do |column, index|
              td(class: "#{index == 0 ? "w-100 bl f-3" : "f-2"} pa-2 lh-copy va-middle bb br bc-gray-600") do
                column_value(adr,column)
              end
            end
            td(class:"pa-2 tr va-middle bb br bc-gray-600") do
              a(class: "blue-400 ws-nowrap", href: action_routing(adr).to_s) do
                t(page: action_name)
              end
            end
          end
        end
      end
    end
  else
    p(class:"ma-3 p i") { t(page: :none) }
  end
    end
  end
end
