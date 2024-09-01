class NewDraftAdrPage < AppPage
  attr_reader :form, :error_message
  def initialize(form: nil, account:)
    @form = form || NewDraftAdrForm.new
    @account = account
    @error_message = if !@form.new? && form.constraint_violations?
                       "pages.adrs.new.adr_invalid"
                     else
                       nil
                     end
  end

  def refines_adr  = DataModel::Adr[external_id: @form.refines_adr_external_id, account_id: @account.id]
  def replaces_adr = DataModel::Adr[external_id: @form.replaced_adr_external_id, account_id: @account.id]

end
