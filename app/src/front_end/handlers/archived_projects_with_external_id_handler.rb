class ArchivedProjectsWithExternalIdHandler < AppHandler
  def initialize(external_id:, authenticated_account:, flash:)
    @external_id = external_id
    @authenticated_account = authenticated_account
    @flash = flash
  end

  def handle
    project = Project.find!(external_id: @external_id, account: @authenticated_account.account)
    project.archive
    @flash.notice = :project_archived
    redirect_to(AccountByExternalIdPage, external_id: @authenticated_account.external_id, tab: :projects)
  end
end
