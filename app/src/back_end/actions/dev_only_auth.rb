class Actions::DevOnlyAuth < AppAction

  def check(email)
    if Brut.container.project_env.production?
      return { error: "Login failed" }
    end
    result = new_result
    account = DataModel::Account[email: email]
    if account
      result[:account] = account
    else
      result.constraint_violation!(object: email, field: :email, key: :no_account)
    end
    result
  end

  def call(email)
    self.check(email)
  end
end

