class DeactivateAccount
  def initialize(account:)
    if !account.deactivated?
      raise ArgumentError,"#{account.external_id} is not deactivated"
    end
    @account = account
  end
  def external_id = @account.external_id
  def active? = false
end
