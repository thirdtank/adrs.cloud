class Actions::Login
  def call(form_submission:)
    account = DataModel::Account[email: form_submission.email.to_s]
    if account
      account
    else
      { errors: { email: "No account with this email and password" } }
    end
  end
end

