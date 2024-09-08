class EditDraftAdrByExternalIdPage < AppPage
  attr_reader :draft_adr, :form, :error_message, :info_message
  def initialize(account:, external_id:, form: nil, flash:)
    @draft_adr = DraftAdr.find(external_id:,account:)
    @form = form || EditDraftAdrWithExternalIdForm.new(params: @draft_adr.to_h)
    @error_message = flash.alert
    @info_message = flash.notice
  end
end
