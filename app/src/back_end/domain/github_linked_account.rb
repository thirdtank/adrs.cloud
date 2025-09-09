# Provides access to and logic around an account that is linked 
# to a GitHub account.
class GithubLinkedAccount < AuthenticatedAccount
  include SemanticLogger::Loggable
  extend SemanticLogger::Loggable

  # Find or create a GithubLinkedAccount based on what OmniAuth provided during authentication/oauth.
  #
  # This will return an InternalErrorAccount if:
  #
  # - account exists with the given GitHub uid, but email we have doesn't match email GitHub provided
  # - email provided by GitHub matches an account, but that account is not linked to the uid provided
  #
  # This will raise an error if:
  #
  # - it's called with an OmniAuth hash from a provider OTHER than GitHub
  # - the OmniAuth hash is missing uid or info->email
  #
  # Otherwise:
  #
  # - If there is 
  # - If the underlying DB::Account has been deactivated, a DeactivatedAccount is returned
  # - If there is no DB::ExternalAccount, it's created and a GithubLinkedAccount is returned
  # - otherwise, a GithubLinkedAccount is returned
  #
  # This may seem complicated, however it allows the caller to rely on getting a useful object back
  # that responds to the Account interface.
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

    external_account = DB::ExternalAccount.first(provider:,external_account_id: uid)
    if external_account
      if external_account.account.email == email
        return self.new(account:external_account.account)
      else
        logger.warn("Github uid #{uid} matched account #{external_account.account.external_id}, whose email was NOT #{email}")
        return InternalErrorAccount.new(account:external_account.account,
                                        error:"domain.account.github.uid_used_by_other_account")
      end
    end

    github_linked_account = self.find(email:)

    if github_linked_account.nil?
      return NoAccount.new
    end

    if github_linked_account.inactive?
      return github_linked_account
    end

    if !github_linked_account.account.external_account(provider:).nil?
      logger.warn("Github uid #{uid} was not in our database, however the email provided, #{email} matched another external account")
      return InternalErrorAccount.new(account:github_linked_account.account,
                                      error:"domain.account.github.uid_changed")
    end

    DB::ExternalAccount.create(
      account: github_linked_account.account,
      provider:,
      external_account_id: uid
    )

    github_linked_account
  end

  # Find a GithubLinkedAccount by either email or external_id
  def self.find(email: nil, external_id:nil)
    if email.nil? && external_id.nil?
      raise ArgumentError,"You must provide either email or external_id"
    elsif !email.nil? && !external_id.nil?
      raise ArgumentError, "You may not provide both email and external_id"
    end

    account = if email
                DB::Account.find(email:)
              else
                DB::Account.find(external_id:)
              end

    if account.nil?
      return NoAccount.new
    end

    if account.deactivated?
      return DeactivatedAccount.new(account:)
    end

    self.new(account:)
  end

  def self.create(form:)
    email = form.email.to_s.downcase.strip
    github_linked_account = self.find(email:)

    if github_linked_account.error?
      raise
    end
    if github_linked_account.exists?
      if github_linked_account.active?
        form.server_side_constraint_violation(input_name: :email, key: :account_exists)
      else
        form.server_side_constraint_violation(input_name: :email, key: :account_deactivated)
      end
    end

    if form.constraint_violations?
      return form
    end

    DB.transaction do
      account = DB::Account.create(email:)
      AccountEntitlements.new(account:).grant_for_new_user
      DB::Project.create(account:,name: "Default", adrs_shared_by_default: false)
      self.new(account:)
    end
  end

  def deactivate!
    if @account.deactivated?
      bug! "#{@account.external_id} is already deactivated"
    end
    @account.update(
      deactivated_at: Time.now,
      external_id: "adac_" + Digest::MD5.hexdigest(SecureRandom.uuid) # XXX: do this better
    )
  end

end
