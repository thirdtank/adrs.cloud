class Actions::GitHubAuth < AppAction

  def check(omniauth_hash)
    provider = omniauth_hash["provider"]
    if provider.to_s.downcase != "github"
      raise "#{self.class} was asked to process  a '#{provider}' provider, not 'github'"
    end

    uid      = omniauth_hash["uid"].to_s.strip
    email    = omniauth_hash.dig("info", "email").to_s.strip

    if uid == ""
      raise "Problem with GitHub auth: we did not get a uid:\n#{omniauth_hash}"
    end
    if email == ""
      raise "Problem with GitHub auth: we did not get an email from 'info':\n#{omniauth_hash['info']}"
    end

    account = DataModel::Account[email: email]
    if account
      return { account: account }
    end
    { error: "'#{email}' has no account" }
  end

  def call(omniauth_hash)
    self.check(omniauth_hash)
  end
end

