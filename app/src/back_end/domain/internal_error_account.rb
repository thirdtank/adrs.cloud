class InternalErrorAccount < Account
  attr_reader :error_i18n_key
  def initialize(account:,error:)
    super(account:)
    @error_i18n_key = error
  end

  def active? = raise "This should not have been called"
  def error?  = true
end
