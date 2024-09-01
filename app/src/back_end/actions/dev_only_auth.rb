class Actions::DevOnlyAuth < AppAction

  def auth(email)
    if Brut.container.project_env.production?
      return nil
    end
    DataModel::Account[email: email]
  end
end

