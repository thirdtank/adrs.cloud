class EditProjectWithExternalIdHandler < AppHandler
  def initialize(external_id:, form:, authenticated_account:, flash:)
    @external_id = external_id
    @form = form
    @authenticated_account = authenticated_account
    @flash = flash
  end

  def handle
    project = @authenticated_account.projects.find!(external_id: @external_id)
    project.save(form: @form)
    if @form.constraint_violations?
      @flash.alert = :save_project_invalid
      EditProjectByExternalIdPage.new(form: @form, external_id: project.external_id, authenticated_account: @authenticated_account)
    else
      @flash.notice = :project_updated
      redirect_to(AccountByExternalIdPage, external_id: @authenticated_account.external_id, tab: "projects")
    end
  end
end
