class EditDraftAdrByExternalIdPage < AppPage
  attr_reader :adr, :form, :error_message
  def initialize(account: nil, external_id: nil, adr: nil, form: nil, error_message: nil)
    if !account || !external_id
      if !adr
        raise ArgumentError,"To create a #{self.class}, you must provide either an Adr or an account/external_id"
      end
    else
    end
    @adr = adr || DataModel::Adr[account_id: account.id, external_id: external_id]
    @form = form || EditDraftAdrWithExternalIdForm.from_adr(@adr)
    @error_message = error_message
  end
end
