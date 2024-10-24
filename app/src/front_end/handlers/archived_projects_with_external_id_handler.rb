class ArchivedProjectsWithExternalIdHandler < AppHandler
  def handle(external_id:, authenticated_account:, flash:)
    project = Project.find!(external_id:,account:authenticated_account.account)
    project.archive
    flash.notice = :project_archived
    redirect_to(AccountByExternalIdPage, external_id: authenticated_account.external_id, tab: :projects)
  end
end
