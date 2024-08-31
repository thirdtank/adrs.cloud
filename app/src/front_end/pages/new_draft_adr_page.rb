class NewDraftAdrPage < AppPage
  attr_reader :form, :error_message
  def initialize(form: nil, constraint_violations: {})
    @form = form || NewDraftAdrForm.new
    @error_message = if !@form.new? && form.invalid?
                       "pages.adrs.new.adr_invalid"
                     else
                       nil
                     end
  end

end
