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
end
