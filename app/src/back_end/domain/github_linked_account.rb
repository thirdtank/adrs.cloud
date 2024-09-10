class GithubLinkedAccount < AuthenticatedAccount
  def self.find_from_omniauth_hash(omniauth_hash:)
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
    self.find(email:)
  end

  def self.find(email: nil, external_id:nil)
    if email.nil? && external_id.nil?
      raise ArgumentError,"You must provide either email or external_id"
    elsif !email.nil? && !external_id.nil?
      raise ArgumentError, "You may not provide both email and external_id"
    end
    account = if email
                DataModel::Account[email: email]
              else
                DataModel::Account[external_id: external_id]
              end
    if account.nil?
      NoAccount
    elsif account.deactivated?
      NoAccount
    else
      self.new(account:)
    end
  end

  def self.create(form:)
    email = form.email.to_s.downcase.strip
    existing_account = self.find(email:)
    if existing_account.exists?
      form.server_side_constraint_violation(input_name: :email, key: :account_exists)
    end
    if form.constraint_violations?
      return form
    end

    DataModel::Account.transaction do
      account = DataModel::Account.create(email:,created_at:Time.now)
      AccountEntitlements.new(account:).grant_for_new_user
      self.new(account:account)
    end
  end

  def deactivate!
    if @account.deactivated?
      raise Brut::BackEnd::Errors::Bug,"#{@account.external_id} is already deactivated"
    end
    @account.update(
      deactivated_at: Time.now,
      external_id: "adac_" + Digest::MD5.hexdigest(SecureRandom.uuid)
    )
  end

end
