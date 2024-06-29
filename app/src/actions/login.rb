class Actions::Login < AppAction

  def check(form:)
    result = self.check_result
    account = DataModel::Account[email: form.email.to_s]
    if account
      result.save_context(account: account)
    else
      result.constraint_violation!(object: form, field: :email, key: :no_account)
    end
    result
  end

  def call(form:)
    self.check(form: form)
  end
end

