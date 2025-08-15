class NoAccount < Account
  def initialize
    super(account:nil)
  end
  def active? = false
  def error?  = false
  def exists? = false
end
