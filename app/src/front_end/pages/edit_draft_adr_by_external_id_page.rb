class EditDraftAdrByExternalIdPage < AppPage
  attr_reader :draft_adr, :form, :projects
  def initialize(authenticated_account:, external_id:, form: nil)
    @draft_adr     = authenticated_account.draft_adrs.find!(external_id:)
    @form          = form || EditDraftAdrWithExternalIdForm.new(params: @draft_adr.to_params)
    @projects      = authenticated_account.projects.active
  end
  # XXX: Remove or recreate this
  def adr_path(adr) = AdrsByExternalIdPage.routing(external_id: adr.external_id)
end
