module Pages::DraftAdrs
end
class Pages::DraftAdrs::New < AppPage
  attr_reader :form, :error_message
  def initialize(form:)
    @form = form
    @error_message = if !@form.new? && form.invalid?
                       "pages.adrs.new.adr_invalid"
                     else
                       nil
                     end
  end

end
