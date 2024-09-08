class NewDraftAdrPage < AppPage
  attr_reader :form, :error_message, :refines_adr, :replaces_adr
  def initialize(form: nil, account:)
    @form = form || NewDraftAdrForm.new
    @account = account
    @error_message = if !@form.new? && form.constraint_violations?
                       :adr_invalid
                     else
                       nil
                     end
    @refines_adr  = AcceptedAdr.search(external_id: @form.refines_adr_external_id,account:)
    @replaces_adr = AcceptedAdr.search(external_id: @form.replaced_adr_external_id,account:)
  end


end
