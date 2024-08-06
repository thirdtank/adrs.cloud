class Actions::DevOnlyAuth < AppAction

  def check(email)
    account = DataModel::Account[email: email]
    if account
      return { account: account }
    end
    { error: "'#{email}' has no account" }
  end

  def call(omniauth_hash)
    self.check(omniauth_hash)
  end
end

