class AccountByExternalIdPage < AppPage2
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

  def page_template
    section(class: "flex w-100") do
      nav(class: "bg-gray-200 gray-800 w-6 h-100vh flex flex-column justify-between") do
        div(class: "flex flex-column overflow-y-scroll") do
          div(class: "flex flex-column gap-2 items-center") do
            header(class: "h-4 pa-3 flex items-center gap-2 w-100 mt-3") do
              h1(class: "f-4 ma-0 flex items-center gap-2") do
                span(class: "f-5") do
                  inline_svg("architectural-icon")
                end
                raw(t(:adrscloud))
              end
            end
          end
          brut_tabs(
            role: "tablist",
            aria_orientation: "vertical",
            class: "adr-page-tabs",
            show_warnings:true,
            tab_selection_pushes_and_restores_state: true
          ) do
            tabs.each do |tab|
              a(
                href: "?tab=tab.name",
                role:"tab",
                aria_selected: (tab == selected_tab).to_s,
                tabindex: tab == selected_tab ? 0 : -1,
                aria_controls: "#{tab.name}-panel",
                id:"#{tab.name}-tab",
                class: "ws-nowrap"
              ) do
                span(class: "flex items-center justify-end gap-2") do
                  span { t(page: [ "tabs", tab.name, "title" ] ) }
                  span(class: "w-2") { inline_svg(tab.icon) }
                end
              end
            end
          end
        end
        div(class: "w-100 bg-gray-300 gray-900 flex flex-column gap-2 ph-3 pv-3") do
          a(class: "orange-800 f-1 db", href:AdrsPage.routing.to_s) {  t(page: :your_adrs) }
          a(class: "orange-800 f-1 db", href:HelpPage.routing.to_s) { t(:help) }
          a(class: "orange-800 f-1 db", href:LogoutHandler.routing.to_s) { t(:logout) }
        end
      end
      section(class: "bg-gray-900 gray-100 w-100 h-100vh pb-3 flex flex-column items-start") do
        global_component(AnnouncementBannerComponent)
        div(class: "overflow-y-scroll w-100") do
          render(AccountByExternalIdPage::TabPanelComponent.new(tab_name: "projects", selected_name: selected_tab.name)) do
            table(class: "collapse mv-3 striped w-100") do
              caption(class: "sr-only") { "Projects" }
              thead do
                tr do
                  th(class: "tl ws-nowrap f-1 ttu b pa-2 bb bc-gray-600") do
                    t(page: "projects.columns.name" )
                  end
                  th(class: "tl ws-nowrap f-1 ttu b pa-2 bb bc-gray-600") do
                    t(page: "projects.columns.description" )
                  end
                  th(class: "tl ws-nowrap f-1 ttu b pa-2 bb bc-gray-600") do
                    t(page: "projects.columns.sharing" )
                  end
                  th(class: "tl ws-nowrap f-1 ttu b pa-2 bb bc-gray-600") do
                    span(class: "sr-only") do
                      t(page: "projects.columns.actions" )
                    end
                  end
                end
              end
              tbody do
                authenticated_account.projects.each do |project|
                  tr(title:project.name) do
                    td(class: "ws-nowrap bl pa-2 lh-copy va-middle bb br bc-gray-600") do
                      plain(project.name)
                      if project.archived?
                        span(class: "dib f-1 ph-2 pv-1 bg-red-900 gray-400 ba bc-gray-700 br-bl-4 br-tl-1 br-br-1 br-tr-4") { 
                          t(page: [ "projects", "archived" ])
                        }
                      end
                    end
                    td(class: "measure p f-1 pa-2 lh-copy va-middle bb br bc-gray-600") do
                      project.description
                    end
                    td(class: "pa-2 lh-copy va-middle bb br bc-gray-600") do
                      div(class: "flex items-center gap-2") do
                        if project.adrs_shared_by_default
                          span(class: "w-2 flex flex-column justify-center") {
                            inline_svg("globe-network-icon")
                          }
                          span {
                            t(page: [ "projects", "default_shared" ])
                          }
                        else
                          span(class: "w-2 flex flex-column justify-center") { inline_svg("lock-icon") }
                          span { t(page: [ "projects", "default_private" ]) }
                        end
                      end
                    end
                    td(class: "pa-2 tr va-middle bb br bc-gray-600") do
                      div(class: "flex items-baseline gap-2") do
                        a(
                          class: "blue-400 ws-nowrap",
                          href: EditProjectByExternalIdPage.routing(external_id: project.external_id).to_s
                        ) {
                          t(:edit) 
                        }
                        if project.active?
                          form_tag(action: ArchivedProjectsWithExternalIdHandler.routing(external_id: project.external_id).to_s, method: :post) do
                            brut_confirm_submit(
                              message: t(page: "projects.archive_confirmation")
                            ) do
                              button(class: "tdu pointer blue-400 bn bg-none") {
                                t(page: "projects.archive")
                              }
                            end
                          end
                        end
                      end
                    end
                  end
                end
              end
            end
            if authenticated_account.entitlements.can_add_new_project?
              a(
                href: NewProjectPage.routing.to_s,
                class: "db pv-3 blue-300 f-3"
              ) {
                t(page: "projects.add_new")
              }
            else
              p(class: "p i gray-400") do
                raw(t(page: :project_limit_exceeded))
                raw(t(page: :contact_support_for_limit_increase))
              end
            end
          end
          render(AccountByExternalIdPage::TabPanelComponent.new(tab_name: "download", selected_name: selected_tab.name)) do
            if authenticated_account.has_download?
              adr_check_download(
                aria_live: "polite",
                aria_atomic: "true",
                log_request_errors: true,
                download_url: ReadyDownloadsWithExternalIdHandler.routing(external_id: authenticated_account.download.external_id).to_s,
                ready: authenticated_account.download.ready?,
                show_warnings: true
              ) do
                render(AccountByExternalIdPage::DownloadProgressComponent.new(download: authenticated_account.download))
              end
            else
              form_tag(for: DownloadsHandler) do
                render(ButtonComponent.new(
                  size: :large,
                  color: :green,
                  label: t(page: "download.create_download"),
                  icon: "database-download-icon",
                ))
                p(class: "p i") do
                  t(page: "download.create_download_explanation")
                end
              end
            end
          end
          render(AccountByExternalIdPage::TabPanelComponent.new(tab_name: "info", selected_name: selected_tab.name)) do
            h3(class: "f-3 ma-0") { t(page: "info.personal.title") }
            dl(class: "dl-grid gap-2 ml-3") do
              dt(class: "b") { t(page: "info.personal.email.title") }
              dd { 
                plain(authenticated_account.account.email)
                sup { raw(safe("&dagger;")) }
              }
              if timezone_from_browser
                dt(class: "b") { t(page: "info.personal.timezone.title") }
                dd {
                  plain(timezone_from_browser.to_s)
                  sup { raw(safe("&ddagger;")) }
                }
              end
              dt(class: "b") { t(page: "info.personal.locale.title") }
              if http_accept_language.known?
                dd { 
                  plain(http_accept_language.weighted_locales.map(&:locale).join(", "))
                  sup { raw(safe("&ddagger;")) }
                }
              else
                dd { t(page: "info.personal.locale.unknown") }
              end
            end
            p(class: "i f-1 p ml-3 mb-0 gray-400") do
              sup { raw(safe("&dagger;")) }
              raw(t(page: "info.personal.email.note"))
            end
            p(class: "i f-1 p ml-3 mt-0 gray-400") do
              sup { raw(safe("&ddagger;")) }
              raw(t(page: "info.personal.timezone.note"))
            end
            h3(class: "f-3 ma-0 mt-4" ) { t(page: "info.limits.title") }
            p(class: "p ma-0 fw-4 mt-2") do
              raw(t(page: :contact_support_for_limit_increase))
            end
            div(class: "w-50 pa-3 flex flex-column items-center") do
              meter(
                class: "w-100",
                value: authenticated_account.entitlements.non_rejected_adrs,
                high: authenticated_account.entitlements.max_non_rejected_adrs * 0.85,
                min: 0,
                max: authenticated_account.entitlements.max_non_rejected_adrs
              )
              div(class: "p f-1 gray-300") do
                if authenticated_account.entitlements.can_add_new?
                  t(:adrs_remaining_counts, num: authenticated_account.entitlements.non_rejected_adrs_remaining, max: authenticated_account.entitlements.max_non_rejected_adrs)
                else
                  p(class: "p ma-0 fw-7 red-300") do
                    t(:add_new_limit_exceeded)
                  end
                end
              end
              meter(
                class: "w-100 mt-3",
                value: authenticated_account.entitlements.num_projects,
                high: authenticated_account.entitlements.max_projects * 0.85,
                min: 0,
                max: authenticated_account.entitlements.max_projects,
              )
              div(class: "p f-1 gray-300") do
                if authenticated_account.entitlements.can_add_new_project?
                  t(:projects_remaining_counts, num: authenticated_account.entitlements.projects_remaining, max: authenticated_account.entitlements.max_projects)
                else
                  p(class: "p ma-0 fw-7 red-300") do
                    t(:project_limit_exceeded)
                  end
                end
              end
            end
          end
        end
      end
    end
    render(ConfirmationDialogComponent)
  end
end
