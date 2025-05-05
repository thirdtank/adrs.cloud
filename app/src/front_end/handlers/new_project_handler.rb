class NewProjectHandler < AppHandler
  def initialize(form:, authenticated_account:, flash:)
    @form = form
    @authenticated_account = authenticated_account
    @flash = flash
  end

  def handle
    if !@authenticated_account.entitlements.can_add_new_project?
      return http_status(403)
    end
    project = Project.create(authenticated_account: @authenticated_account)
    project.save(form: @form)
    if @form.constraint_violations?
      @flash.alert = :new_project_invalid
      NewProjectPage.new(form: @form, authenticated_account: @authenticated_account)
    else
      @flash.notice = :new_project_created
      redirect_to(AccountByExternalIdPage, external_id: @authenticated_account.external_id, tab: "projects")
    end
  end
end
