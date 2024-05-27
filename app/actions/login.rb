class Actions::Login
  def call(form:)
    account = DataModel::Account[email: form.email.to_s]
    if account
      return account
    end
    form.server_side_constraint_violation(input_name: :email, key: :no_account)
    form
  end
end

