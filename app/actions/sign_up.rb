class Actions::SignUp < AppAction
  class ServerSideValidator
    def validate(form:)
      if form.password != form.password_confirmation
        form.server_side_constraint_violation(input_name: :password_confirmation, key: :must_match, context: "password")
      else
        if DataModel::Account[email: form.email.to_s]
          form.server_side_constraint_violation(input_name: :email, key: :is_taken)
        end
      end
    end
  end

  def call(form:)
    DataModel::Account.create(email: form.email, created_at: DateTime.now)
  end
end
