class AcceptedAdrsWithExternalIdHandler < AppHandler
  def initialize(form:, external_id:, authenticated_account:, flash:)
    @form = form
    @external_id = external_id
    @authenticated_account = authenticated_account
    @flash = flash
  end

  def handle
    draft_adr = @authenticated_account.draft_adrs.find!(external_id: @external_id)

    @form = draft_adr.accept(form: @form)

    if @form.constraint_violations?
      @flash.alert = :adr_cannot_be_accepted
      EditDraftAdrByExternalIdPage.new(
        form: @form,
        authenticated_account: @authenticated_account,
        external_id: draft_adr.external_id,
      )
    else
      @flash.notice = :adr_accepted
      redirect_to(AdrsByExternalIdPage, external_id: draft_adr.external_id)
    end
  end
end
