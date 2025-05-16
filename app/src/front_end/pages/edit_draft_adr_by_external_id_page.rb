class EditDraftAdrByExternalIdPage < AppPage
  attr_reader :draft_adr, :form, :projects
  def initialize(authenticated_account:, external_id:, form: nil)
    @draft_adr     = authenticated_account.draft_adrs.find!(external_id:)
    @form          = form || EditDraftAdrWithExternalIdForm.new(params: @draft_adr.to_params)
    @projects      = authenticated_account.projects.active
  end
  # XXX: Remove or recreate this
  def adr_path(adr) = AdrsByExternalIdPage.routing(external_id: adr.external_id)

  def page_template
    adr_edit_draft_by_external_id_page(show_warnings: true) do
      I18nTranslations("pages.EditDraftAdrByExternalIdPage.adr_updated")
      I18nTranslations("pages.EditDraftAdrByExternalIdPage.adr_not_updated")
      render global_component(AnnouncementBannerComponent)
      header do
        h2(class: "tc ma-0 mt-3 ttu tracked-tight f-5") { t(:edit) }
        if draft_adr.refining?
          h3(class:"mt-1 fw-4 f-2 i flex items-center justify-center gap-2") do
            span(class:"w-2 gray-300") do
              inline_svg("adjust-control-icon")
            end
            span do
              raw(
                t(:refines) {
                  a(
                    class: "blue-300",
                    href: adr_path(draft_adr.adr_refining)
                  ) {
                    draft_adr.adr_refining.title
                  }
                }
              )
            end
          end
        end
        if draft_adr.replacing?
          h3(class: "mt-1 fw-4 f-2 i flex items-center justify-center gap-2") do
            span(class: "w-2 gray-300") do
              inline_svg("change-icon")
            end
            span do
              raw(
                t(:proposed_replacement) {
                  a(
                    class: "blue-300",
                    href: adr_path(draft_adr.adr_replacing)
                  ) {
                    draft_adr.adr_replacing.title
                  }
                }
              )
            end
          end
        end
      end
      section(class: "pa-3") do
        render(Adrs::FormComponent.new(form, action: :edit, external_id: @draft_adr.external_id, projects: projects))
      end
    end
  end
end
