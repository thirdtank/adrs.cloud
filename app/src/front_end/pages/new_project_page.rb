class NewProjectPage < AppPage
  attr_reader :form, :account_external_id
  def initialize(form:nil, authenticated_account:)
    @form                = form || NewProjectForm.new
    @account_external_id = authenticated_account.external_id
  end

  def page_template
    global_component(AnnouncementBannerComponent)
    header do
      h2(class: "tc ma-0 mt-3 ttu tracked-tight f-5") do
        t(:new_project)
      end
    end
    section(class: "pa-3") do
      render Projects::FormComponent.new(form,action: :new, account_external_id: account_external_id)
    end
  end
end
