class EditProjectWithExternalIdHandler < AppHandler
  def handle!(external_id:,form:,authenticated_account:,flash:)
    project = authenticated_account.projects.find!(external_id:)
    project.save(form:)
    if form.constraint_violations?
      flash.alert = :save_project_invalid
      EditProjectByExternalIdPage.new(form:form,external_id:project.external_id,authenticated_account:)
    else
      flash.notice = :project_updated
      redirect_to(AccountByExternalIdPage, external_id: authenticated_account.external_id, tab: "projects")
    end
  end
end
