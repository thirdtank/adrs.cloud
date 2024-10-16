class DeactivatedAccount < Account
  def initialize(account:)
    if !account.deactivated?
      raise ArgumentError,"#{account.external_id} is not deactivated"
    end
    super(account:)
  end
  def external_id = self.account.external_id
  def active? = false
  def error?  = false
end
