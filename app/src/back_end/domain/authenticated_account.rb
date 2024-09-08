class AuthenticatedAccount
  attr_reader :account, :session_id
  def self.find(session_id:)
    account = DataModel::Account[external_id: session_id]
    if account.nil?
      NoAccount
    else
      self.new(account:)
    end
  end

  def initialize(account:)
    @account    = account
    @session_id = account.external_id
  end
  def exists? = true

  class NoAccount
    def self.exists? = false
  end
end
