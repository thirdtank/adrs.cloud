class DeveloperOnlyAccount < AuthenticatedAccount
  def self.find(email:)
    if Brut.container.project_env.production?
      return nil
    end
    account = DataModel::Account[email: email]
    if account.nil?
      NoAccount
    else
      self.new(account:)
    end
  end
end
