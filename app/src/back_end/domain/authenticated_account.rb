class AuthenticatedAccount
  attr_reader :account, :session_id
  def self.search(session_id:)
    account = DataModel::Account[external_id: session_id]
    if account.nil?
      nil
    elsif account.deactivated?
      DeactivateAccount.new(account:)
    else
      self.new(account:)
    end
  end

  def initialize(account:)
    if account.deactivated?
      raise ArgumentError,"#{account.external_id} has been deactivated"
    end
    @account    = account
    @session_id = account.external_id
  end
  def active? = true

end
