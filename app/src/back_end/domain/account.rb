class Account
  attr_reader :account
  def initialize(account:) # DB::Account
    @account = account
  end

  def active? = raise "Subclass must implement"
  def error?  = raise "Subclass must implement"
end
