class AuthenticatedAccount
  attr_reader :account, :session_id

  def self.find(session_id:)
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
      @klass.find!(**(args.merge(@args)))
    end
    def find(**args)
      @klass.find(**(args.merge(@args)))
    end
  end

  class AdrsFindable < Findable
    def search(tag:nil)
      account = @args.fetch(:account)
      adrs = if tag.nil?
               account.adrs
             else
               tag = tag.downcase
               if (tag == DB::Adr.phony_tag_for_shared)
                 account.adrs_dataset.where(Sequel.lit("shareable_id IS NOT NULL")).to_a
               else
                 account.adrs_dataset.where(Sequel.lit("tags @> ?",Sequel.pg_array([tag]))).to_a
               end
             end
      adrs
    end
  end

  def accepted_adrs
    Findable.new(AcceptedAdr,account:)
  end

  def draft_adrs
    Findable.new(DraftAdr,account:)
  end

  def adrs
    AdrsFindable.new(DB::Adr,account:)
  end

  def entitlements
    AccountEntitlements.new(account:)
  end

end
