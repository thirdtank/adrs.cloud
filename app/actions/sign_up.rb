class Actions::SignUp < AppAction
  def call(form:)
    result = self.check(form: form)
    if result.can_call?
      account = DataModel::Account.create(email: form.email, created_at: DateTime.now)
      result.save_context(account: account)
    end
    result
  end

  def check(form:)
    result = self.check_result
    if form.password != form.password_confirmation
      result.constraint_violation!(object: form, field: :password_confirmation, key: :must_match)
    end
    if DataModel::Account[email: form.email.to_s]
      result.constraint_violation!(object: form, field: :email, key: :is_taken)
    end
    result
  end
end
