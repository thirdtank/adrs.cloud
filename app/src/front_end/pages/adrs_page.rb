class AdrsPage < AppPage

  class SearchForm < Brut::FrontEnd::Form
    select :project_external_id, required: false
    input :tax, required: false
  end

  attr_reader :tag, :tab, :entitlements, :authenticated_account, :project

  def initialize(authenticated_account:, tag: nil, tab: "accepted", project_external_id: nil)
    @authenticated_account = authenticated_account
    @tag                   = RichString.new(tag).to_s_or_nil
    @project               = if project_external_id == "ALL" || project_external_id.nil?
                               nil
                             else
                               Project.find!(external_id: project_external_id, account: authenticated_account.account)
                             end

    @adrs                  = @authenticated_account.adrs.search(tag: @tag,project: @project)

    num_non_rejected_adrs = @adrs.length - self.rejected_adrs.length

    @entitlements = @authenticated_account.entitlements
    @tab          = tab.to_sym
    @search_form  = SearchForm.new(params: {
      project_external_id: @project&.external_id,
      tag: @tag
    })
  end

  def filtered? = !!@tag || !!@project

  def accepted_adrs = @adrs.select(&:accepted?).reject(&:replaced?).sort_by(&:accepted_at)
  def replaced_adrs = @adrs.select(&:replaced?).sort_by { |adr|
    adr.replaced_by_adr.accepted_at
  }
  def draft_adrs    = @adrs.reject(&:accepted?).reject(&:rejected?).sort_by(&:created_at)
  def rejected_adrs = @adrs.select(&:rejected?).sort_by(&:rejected_at)

  def can_add_new? = @entitlements.can_add_new?


  def page_template
    section(class:"flex w-100") do
      nav(class:"bg-gray-200 gray-800 w-6 h-100vh flex flex-column justify-between") do
        div(class:"flex flex-column overflow-y-scroll") do
          header(class:"pa-3 w-100 pt-4 flex items-center gap-2") do
            h1(class:"f-4 ma-0 flex items-center gap-2") do
              span(class:"f-5") {
                inline_svg("architectural-icon")
              }
              raw(t(:adrscloud))
            end
          end
          div(class:"pb-3 pr-3") do
            if can_add_new?
              a(
                href: NewDraftAdrPage.routing,
                class: "green-500 bc-green-200 f-3 tc w-100 db bt bb br br-right-1 bg-black pa-2 active-bg-gray-300"
              ) do
                t(:add_new)
              end
            else
              span(class:"gray-700 i bc-gray-200 f-3 tc w-100 db bt bb br br-right-1 pa-2 bg-gray-600 cursor-not-allowed", title: t(:add_new_limit_exceeded)) do
                t(:add_new)
              end
            end
          end
          render(
            AdrsPage::TabComponent.new(
              tabs: {
                accepted: "check-mark-icon",
                drafts: "edit-list-icon",
                replaced: "change-icon",
                rejected: "recycle-bin-line-icon",
              },
              selected_tab: tab,
              css_class: "adr-page-tabs",
            )
          )
        end
        div(class:"w-100 bg-gray-300 gray-900 flex flex-column gap-2 ph-3 pv-3") do
          a(
            class:"orange-800 f-1 db",
            href: AccountByExternalIdPage.routing(external_id: authenticated_account.external_id)
          ) do
            t(:your_account)
          end
          a(class:"orange-800 f-1 db",href: HelpPage.routing) { t(:help) }
          a(class:"orange-800 f-1 db",href: LogoutHandler.routing) { t(:logout)}
        end
      end
      section(class:"bg-gray-900 gray-100 w-100 h-100vh pb-3 flex flex-column items-start") do
        render global_component(AnnouncementBannerComponent)
        div(class:"overflow-y-scroll w-100") do
          div(class:"mh-3 mt-3 shadow-1 dib bg-purple-900 br-2") do
            adr_include_query_params do
              form(class:"pa-3 flex items-center gap-3 bb bc-gray-700") do
                label(class:"flex items-center gap-2") do
                  span(class:"f-1 fw-6") { "Project:" }
                  brut_autosubmit do
                    Inputs::SelectTagWithOptions(
                      form: @search_form,
                      input_name: "project_external_id",
                      include_blank: { value: "ALL", text_content: "All" },
                      options: authenticated_account.projects,
                      value_attribute: :external_id,
                      option_text_attribute: :name,
                      html_attributes: { class: "w-6" }
                    )
                  end
                end
                label(class:"flex items-center gap-2") do
                  span(class:"f-1 fw-6") { "Tag:" }
                  input(
                    type: "search",
                    name: "tag",
                    value: tag,
                    id: "tag-search-input",
                    class: "text-field text-field--tiny",
                    placeholder: t(:tag_filter_placeholder)
                  )
                end
                render(
                  ButtonComponent.new(
                    size: :tiny,
                    color: :purple,
                    label: "Filter",
                    icon: "layer-icon"
                  )
                )
                if filtered?
                  a(
                    href: "?",
                    class: "blue-400 f-1"
                  ) do
                    t(:remove_filter)
                  end
                end
              end
            end
          end
          render(
            AdrsPage::TabPanelComponent.new(adrs: accepted_adrs,
                                            tag: tag,
                                            project: project,
                                            selected: tab == :accepted,
                                            tab: :accepted,
                                            columns: [ :title, :project, :accepted_at ],
                                            action: :view)
          )
          render(
            AdrsPage::TabPanelComponent.new(adrs: draft_adrs,
                                            tab: :drafts,
                                            tag: tag,
                                            project: project,
                                            selected: tab == :drafts,
                                            columns: [ :title, :project, :created_at ],
                                            action: :edit)
          )
          render(
            AdrsPage::TabPanelComponent.new(adrs: replaced_adrs,
                                            selected: tab == :replaced,
                                            tab: :replaced,
                                            tag: tag,
                                            project: project,
                                            columns: [ :title, :project, :created_at ],
                                            action: :view)
          )
          render(
            AdrsPage::TabPanelComponent.new(adrs: rejected_adrs,
                                            tab: :rejected,
                                            selected: tab == :rejected,
                                            tag: tag,
                                            project: project,
                                            columns: [ :title, :project, :created_at, :rejected_at ],
                                            action: :view)
          )
        end
      end
    end
  end
end

