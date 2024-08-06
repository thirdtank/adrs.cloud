class Actions::DevOnlyAuth < AppAction

  def check(email)
    if Brut.container.project_env.production?
      return { error: "Login failed" }
    end
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

