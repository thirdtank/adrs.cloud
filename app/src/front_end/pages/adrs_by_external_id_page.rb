class AdrsByExternalIdPage < AppPage2
  attr_reader :adr

  def initialize(authenticated_account:, external_id:)
    @adr          = authenticated_account.adrs.find!(external_id:)
    @can_add_new  = authenticated_account.entitlements.can_add_new?
  end

  def can_add_new? = @can_add_new
  def can_edit_tags? = self.accepted?
  # XXX: Remove or recreate this
  def adr_path(adr) = AdrsByExternalIdPage.routing(external_id: adr.external_id).to_s

  def field(name, label_additional_clases: "")
    section(aria_label: name, class: "flex flex-column gap-2 ph-3") {
      h4(class: "ma-0 f-1 ttu fw-6 #{label_additional_clases}") {
        t(page: [ :fields, name ])
      }
      div(class: "measure-wide rendered-markdown") {
        render(MarkdownStringComponent.new(adr.send(name)))
      }
    }
  end

  def refined_by_adrs
    adr.refined_by_adrs.reject(&:rejected?).reject(&:replaced?)
  end

  def editable? = !adr.accepted? && !adr.rejected?
  def draft? = self.editable?
  def accepted? = adr.accepted?

  def private? = !self.shared?
  def shared?  =  adr.shared?

  def accepted_i18n_key = adr.replaced? ? :originally_accepted : :accepted

  def tags = Tags.from_array(array: adr.tags(phony_shared: false))

  def banner(**args,&block)
    render(AdrsByExternalIdPage::BannerComponent.new(**args),&block)
  end

  def page_template
    section(class: "flex w-100") do
      nav(class: "bg-gray-800 gray-100 w-6 h-100vh flex flex-column justify-between") do
        div(class: "flex flex-column overflow-y-scroll") do
          div(class: "pa-3 w-100 pt-4 bg-gray-200 gray-800") do
            header(class: "flex items-center gap-2") do
              h1(class: "f-4 ma-0 flex items-center gap-2") do
                span(class: "f-5") do
                  inline_svg("architectural-icon")
                end
                plain(t(:adrscloud).to_s)
              end
            end
            a(class: "f-2 fw-5 blue-800 db pt-3",
              href:AdrsPage.routing.to_s
             ) do
               raw(safe("&larr; #{t(:view_all)}"))
             end
          end
          div(class: "ph-3 bt bc-gray-500 pv-2") do
            div(class: "flex flex-column gap-3 items-end mt-1 pb-3 bb bc-gray-600") do
              if editable?
                a(class: "db mt-3 w-100 tc pv-2 ba br-1 bc-blue-500 f-2 fw-5 blue-400", href: "EditDraftAdrByExternalIdPage.routing(external_id: adr.external_id)") do
                  t(page: :edit_adr)
                end
              elsif accepted?
                form_tag(method: "post", class: "flex flex-column items-start gap-2 mb-2 w-100") do
                  input(type:"hidden", name:"external_id", value: adr.external_id)
                  fieldset(class: "bn pa-0 ma-0 flex w-100 items-center") do

                    render(
                      ButtonComponent.new(
                        size: "tiny",
                        formaction: SharedAdrsWithExternalIdHandler.routing(external_id: adr.external_id),
                        disabled: shared? ? t(page: :already_shared) : false,
                        color: "orange",
                        variant: :left,
                        label: t(page: :share),
                        confirm: t(page: :share_confirm),
                        width: :full,
                        icon: "globe-network-icon")
                    )

                    render(
                      ButtonComponent.new(
                        size: "tiny",
                        formaction: PrivateAdrsWithExternalIdHandler.routing(external_id: adr.external_id),
                        disabled: private? ? t(page: :not_shared) : false,
                        color: "blue",
                        variant: :right,
                        label: t(page: :stop_sharing_short),
                        aria_label: t(page: :stop_sharing),
                        confirm: t(page: :stop_share_confirm),
                        width: :full,
                        icon: "lock-icon")
                    )

                  end
                  if shared?
                    a(
                      class: "blue-300 f-1 db flex items-center justify-end gap-1 pr-1 w-100",
                      target:"_blank",
                      href: SharedAdrsByShareableIdPage.routing(shareable_id: adr.shareable_id).to_s
                    ) do
                      span { inline_svg("external-link-icon") }
                      span { t(page: :view_share_page) }
                    end
                  end
                end
                if !adr.replaced?
                  form_tag(method: "post", class:"flex items-center w-100") do
                    input(type: "hidden", name: "external_id", value: "adr.external_id")
                    render(
                      ButtonComponent.new(
                        size: "tiny",
                        variant: :left,
                        formaction: ReplacedAdrsWithExistingExternalIdHandler.routing(existing_external_id: adr.external_id),
                        disabled: can_add_new? ? false : t(:add_new_limit_exceeded),
                        color: "red",
                        width: :full,
                        label: t(page: :replace),
                        icon: "change-icon"
                      )
                    )
                    render(
                      ButtonComponent.new(
                        size: "tiny",
                        variant: :right,
                        formaction: RefinedAdrsWithExistingExternalIdHandler.routing(existing_external_id: adr.external_id),
                        disabled: can_add_new? ? false : t(:add_new_limit_exceeded),
                        color: "purple",
                        width: :full,
                        label: t(page: :refine),
                        icon: "adjust-control-icon"
                      )
                    )
                  end
                end
              end
            end
            adr_tag_editor(show_warnings: "editor") do
              adr_tag_editor_view do
                div(class: "flex flex-column justify-between mb-2 pv-3 gap-3") do
                  div do
                    div(class: "f-1 fw-bold mb-3") { "Tags" }
                    div(class: "flex flex-wrap items-center gap-2") do
                      if adr.tags.any?
                        adr.tags.each do |tag|
                          render(Adrs::TagComponent.new(tag: tag))
                        end
                      else
                        span(class: "f-1 gray-400 i") { t(page: :no_tags) }
                      end
                    end
                  end
                  if can_edit_tags?
                    render(
                      ButtonComponent.new(
                        size: "tiny",
                        color: adr.tags.any? ? "white"             : "purple",
                        label: adr.tags.any? ? t(page: :edit_tags) : t(page: :add_tags),
                        icon:  adr.tags.any? ? "edit-list-icon"    : "plus-round-line-icon"
                      )
                    )
                  end
                end
              end
              if can_edit_tags?
                adr_tag_editor_edit(class: "dn pos-absolute z-2") do
                  form_tag(
                    action: AdrTagsWithExternalIdForm.routing(external_id: adr.external_id).to_s,
                    method: "post",
                    class: "flex flex-column items-end gap-2 mt-2 pa-3 shadow-3 ba bc-gray-700 z-3 bg-white"

                  ) do
                    label(class: "flex flex-column gap-1 w-100") do
                      div(class: "textarea-container") do
                        textarea(name: "tags", class: "textarea") { tags.to_s }
                      end
                      span(class: "sr-only") { Tags }
                      p(class: "p f-1 i ma-0") {
                        "Separate tags by commas or new lines. Tags are case-insensitive"
                      }
                    end
                    div(class: "flex items-center justify-between gap-2 w-100") do
                      render(ButtonComponent.new(size: "tiny",
                                                 type: "reset",
                                                 color: "red",
                                                 label: t(:nevermind),
                                                 icon:  "close-line-icon"))
                      render(ButtonComponent.new(size: "tiny",
                                                 color: "blue",
                                                 label: t(page: :save_tags),
                                                 icon:  "tag-line-icon"))
                    end
                  end
                end
              end
            end
          end
        end
        div(class: "w-100 bg-gray-300 gray-900 flex flex-column gap-2 ph-3 pv-3") do
          a(class: "orange-800 f-1 db", href: "HelpPage.routing"){ t(:help) }
          a(class: "orange-800 f-1 db", href: "LogoutHandler.routing") { t(:logout) }
        end
      end
      section(class: "bg-gray-900 gray-100 w-100 h-100vh flex flex-column items-start shadow-1") do
        global_component(AnnouncementBannerComponent)
        article(class: "overflow-y-scroll w-100 bg-white #{adr.replaced? ? 'gray-600' : 'black'} pos-relative") do
          if draft?
            div(class: "measure-wide pos-relative") do
              aside(
                role: "note",
                class: "ff-cursive f-6 fw-7 red-300 bg-red-600-a20 pa-2 pos-absolute ba br-1 bc-red-300 top-5 right--3",
                style: "transform: rotate(33deg);"
              ) do
                t(:draft)
              end
            end
          end
          h2(class: "measure-narrow pa-3 lh-title f-5 ma-0 #{adr.replaced? ? 'tds' : ''}") { adr.title }
             banner(font_size: "f-1", color: "", background_color: "", font_weight: "fw-4",timestamp: adr.created_at,i18n_key: :created, margins: "mh-3 mv-0")
             div(class: "mb-2") do
               if adr.replaced?
                 banner(color: "red-900", background_color: "bg-red-300") do
                   div(class: "flex items-center gap-3") do
                     div(class: "w-3") do
                       inline_svg("change-icon")
                     end
                     div(class: "tl") do
                       div(class: "flex flex-column gap-2") do
                         div do
                           raw(
                             t(page: :replaced_by) {
                               a(
                                 class: "red-900",
                                 href: adr_path(adr.replaced_by_adr).to_s
                               ) {
                                 adr.replaced_by_adr.title
                               }
                             }
                           )
                         end
                         div(class: "f-1") do
                           raw(
                             t(page: :replaced_on) {
                               time_tag(timestamp: adr.replaced_by_adr.accepted_at, class: "fw-6", format: :date)
                             }
                           )
                         end
                       end
                     end
                   end
                 end
               end
               if accepted?
                 banner(color: adr.replaced?            ? "gray-700"    : "green-800",
                        background_color: adr.replaced? ? "bg-gray-400" : "bg-green-200",
                        font_weight: adr.replaced?      ? "fw-4"        : "fw-5",
                        glow: !adr.replaced?,
                        i18n_key: accepted_i18n_key,
                        timestamp: adr.accepted_at)
               end
               if !adr.replaced_adr.nil?
                 banner(color: "green-200", background_color: "bg-green-900", font_size: "f-1") do
                   raw(
                     t(page: :replaces) {
                       a(
                         class: "green-300",
                         href: adr_path(adr.replaced_adr).to_s
                       ) {
                         adr.replaced_adr.title
                       }
                     }
                   )
                 end
               end
               if adr.refines?
                 banner(color: "blue-200", background_color: "bg-blue-800", font_weight: "fw-4") do
                   div(class: "flex items-center gap-2") do
                     div(class: "w-2") do
                       inline_svg("adjust-control-icon")
                     end
                     div(class: "tl f-1") do
                       raw(
                         t(page: :refines) {
                           a(
                             class: "blue-300",
                             href: adr_path(adr.refines_adr).to_s
                           ) {
                             adr.refines_adr.title
                           }
                         }
                       )
                     end
                   end
                 end
               end
               if adr.rejected?
                 banner(color: "red-800",
                        background_color: "bg-red-200",
                        i18n_key: :rejected,
                        timestamp: adr.rejected_at)
               end
             end
             section(class: "pt-3 adr-content") do
               field("context")
               field("facing")
               div(class: "mb-3 pb-1 pt-3 f-3 measure br-right-2 accepted? ? 'bg-green-800 green-200' : 'bg-yellow-800 yellow-100'",
                   style: "background: linear-gradient(90deg, rgba(236,255,237,1) 11%, rgba(236,255,237,0) 100%);") do
                     field("decision", label_additional_clases: "tdu f-2")
                   end
               field("neglected")
               field("achieve")
               field("accepting")
               field("because")
             end
             render(Adrs::GetRefinementsComponent.new(refined_by_adrs: refined_by_adrs))
        end
      end
    end
    render(ConfirmationDialogComponent.new)
  end

end
