class NewProjectHandler < AppHandler
  def handle!(form:,authenticated_account:,flash:)
    if !authenticated_account.entitlements.can_add_new_project?
      return http_status(403)
    end
    project = Project.create(authenticated_account:)
    project.save(form:)
    if form.constraint_violations?
      flash.alert = :new_project_invalid
      NewProjectPage.new(form:form)
    else
      flash.notice = :new_project_created
      redirect_to(AccountByExternalIdPage, external_id: authenticated_account.external_id, tab: "projects")
    end
  end
end
