class EditProjectByExternalIdPage < AppPage
  attr_reader :form, :project, :account_external_id
  def initialize(form:nil,external_id:,authenticated_account:)
    @project             = DB::Project.find!(external_id: external_id, account: authenticated_account.account)
    @account_external_id = authenticated_account.external_id
    @form                = form || EditProjectWithExternalIdForm.new(params: {
      name: project.name,
      description: project.description,
      adrs_shared_by_default: project.adrs_shared_by_default,
    })
  end

  def page_template
    global_component(AnnouncementBannerComponent)
    header do
      h2(class: "tc ma-0 mt-3 ttu tracked-tight f-5") do
        t(page: :edit_project)
      end
    end
    section(class: "pa-3") do
      render Projects::FormComponent.new(form,action: :edit, external_id: @project.external_id, account_external_id: account_external_id)
    end
  end
end
