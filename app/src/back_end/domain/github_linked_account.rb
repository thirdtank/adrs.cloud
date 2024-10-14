require_relative "authenticated_account"

class GithubLinkedAccount < AuthenticatedAccount
  include SemanticLogger::Loggable
  extend SemanticLogger::Loggable

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
      end
      logger.warn("Github uid #{uid} matched account #{external_account.account.external_id}, whose email was NOT #{email}")
      return InternalErrorAccount.new(account:external_account.account,
                                      error:"domain.account.github.uid_used_by_other_account")
    end
    existing_account = self.find(email:)
    if existing_account.nil?
      return nil
    end
    if !existing_account.active?
      return existing_account
    end
    if !existing_account.account.external_account(provider:).nil?
      logger.warn("Github uid #{uid} was not in our database, however the email provided, #{email} matched another external account")
      return InternalErrorAccount.new(account:existing_account.account,
                                      error:"domain.account.github.uid_changed")
    end
    DB::ExternalAccount.create(account: existing_account.account,provider: provider, external_account_id: uid)
    existing_account
  end

  def self.find(email: nil, external_id:nil)
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
    existing_account = self.find(email:)
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
      account = DB::Account.create(email:)
      AccountEntitlements.new(account:).grant_for_new_user
      DB::Project.create(account:,name: "Default", adrs_shared_by_default: false)
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
