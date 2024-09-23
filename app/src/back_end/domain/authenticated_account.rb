class AuthenticatedAccount
  attr_reader :account, :session_id
  def self.search(session_id:)
    account = DB::Account.find(external_id: session_id)
    if account.nil?
      nil
    elsif account.deactivated?
      DeactivateAccount.new(account:)
    else
      self.new(account:)
    end
  end

  def initialize(account:)
    if account.deactivated?
      raise ArgumentError,"#{account.external_id} has been deactivated"
    end
    @account    = account
    @session_id = account.external_id
  end
  def active? = true

  class Findable
    def initialize(klass,**args)
      @klass = klass
      @args = args
    end

    def find!(**args)
      @klass.find(**(args.merge(@args)))
    end
    def find(**args)
      @klass.search(**(args.merge(@args)))
    end
  end

  def accepted_adrs
    Findable.new(AcceptedAdr,account:)
  end

  def entitlements
    AccountEntitlements.new(account:)
  end

end
