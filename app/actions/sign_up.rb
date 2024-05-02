class Actions::SignUp < AppAction
  class ServerSideValidator
    def validate(form_submission:)
      if form_submission.password != form_submission.password_confirmation
        { password: "must match confirmatoin" }
      else
        if DataModel::Account[email: form_submission.email.to_s]
          { email: "is taken" }
        else
          {}
        end
      end
    end
  end

  def call(form_submission:)
    DataModel::Account.create(email: form_submission.email,
                   created_at: DateTime.now)
  end
end
