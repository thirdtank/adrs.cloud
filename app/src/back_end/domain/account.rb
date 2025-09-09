class Account
  attr_reader :account
  def initialize(account:) 
    @account = account
  end

  def active?   =  raise "Subclass must implement"
  def inactive? = !active?
  def error?    =  raise "Subclass must implement"
  def exists?   =  true
end
