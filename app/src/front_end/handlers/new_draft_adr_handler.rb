class NewDraftAdrHandler < AppHandler
  def initialize(form:, authenticated_account:, flash:)
    @form = form
    @authenticated_account = authenticated_account
    @flash = flash
  end

  def handle
    if !@authenticated_account.entitlements.can_add_new?
      return http_status(403)
    end
    if @form.valid?
      draft_adr = DraftAdr.create(authenticated_account: @authenticated_account)
      @form = draft_adr.save(form: @form)
    end

    if @form.constraint_violations?
      @flash.alert = :new_adr_invalid
      NewDraftAdrPage.new(form: @form, authenticated_account: @authenticated_account, flash: @flash)
    else
      @flash.clear!
      @flash.notice = :adr_created
      redirect_to(EditDraftAdrByExternalIdPage, external_id: draft_adr.external_id)
    end
  end
end
