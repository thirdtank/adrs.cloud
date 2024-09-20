class DeveloperOnlyAccount < AuthenticatedAccount
  def self.search(email:)
    if Brut.container.project_env.production?
      return nil
    end
    account = DB::Account.find(email:)
    if account.nil?
      nil
    else
      self.new(account:)
    end
  end
end
