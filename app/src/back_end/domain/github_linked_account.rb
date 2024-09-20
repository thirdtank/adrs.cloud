class GithubLinkedAccount < AuthenticatedAccount
  def self.search_from_omniauth_hash(omniauth_hash:)
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
    self.search(email:)
  end

  def self.search(email: nil, external_id:nil)
    if email.nil? && external_id.nil?
      raise ArgumentError,"You must provide either email or external_id"
    elsif !email.nil? && !external_id.nil?
      raise ArgumentError, "You may not provide both email and external_id"
    end
    account = if email
                DB::Account.find(email: email)
              else
                DB::Account.find(external_id:)
              end
    if account.nil?
      nil
    elsif account.deactivated?
      DeactivateAccount.new(account:)
    else
      self.new(account:)
    end
  end

  def self.create(form:)
    email = form.email.to_s.downcase.strip
    existing_account = self.search(email:)
    if existing_account
      if existing_account.active?
        form.server_side_constraint_violation(input_name: :email, key: :account_exists)
      else
        form.server_side_constraint_violation(input_name: :email, key: :account_deactivated)
      end
    end
    if form.constraint_violations?
      return form
    end

    DB.transaction do
      account = DB::Account.create(email:,created_at:Time.now)
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
