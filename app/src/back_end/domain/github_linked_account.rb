class GithubLinkedAccount < AuthenticatedAccount
  def self.find(omniauth_hash:)
    provider = omniauth_hash["provider"]
    if provider.to_s.downcase != "github"
      raise "#{self.class} was asked to process a '#{provider}' provider, not 'github'"
    end

    uid   = omniauth_hash["uid"].to_s.strip
    email = omniauth_hash.dig("info", "email").to_s.strip

    if uid == ""
      raise "Problem with GitHub auth: we did not get a uid:\n#{omniauth_hash}"
    end
    if email == ""
      raise "Problem with GitHub auth: we did not get an email from 'info':\n#{omniauth_hash['info']}"
    end

    account = DataModel::Account[email: email]
    if account.nil?
      NoAccount
    else
      self.new(account:)
    end
  end

end
