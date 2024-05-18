class Actions::Login
  def call(form:)
    account = DataModel::Account[email: form.email.to_s]
    if account
      account
    else
      { errors: { email: "No account with this email and password" } }
    end
  end
end

