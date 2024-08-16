class Pages::Adrs::New < AppPage
  attr_reader :form, :updated_message, :error_message
  def initialize(form:, updated_message: nil)
    @form    =   form
    @updated_message = updated_message
    @error_message = if !@form.new? && form.invalid?
                       "ADR is not valid"
                     else
                       nil
                     end
  end

  def updated? = !@updated_message.nil?
end
