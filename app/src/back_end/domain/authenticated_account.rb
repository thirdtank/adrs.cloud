class AuthenticatedAccount < Account

  include Brut::Framework::Errors

  attr_reader :session_id

  def self.find(session_id:)
    account = DB::Account.find(external_id: session_id)
    if account.nil?
      nil
    elsif account.deactivated?
      DeactivatedAccount.new(account:)
    else
      self.new(account:)
    end
  end

  def initialize(account:)
    if account.deactivated?
      raise ArgumentError,"#{account.external_id} has been deactivated"
    end
    super(account:)
    @session_id = account.external_id
  end

  def external_id = @session_id

  def active? = true
  def error?  = false
  def has_download? = !self.download.nil?
  def download = Download.for_account(account: @account)

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

  class ProjectsFindable < Findable
    include Enumerable
    def all
      DB::Project.order(:name).where(**@args)
    end

    def active
      self.all.where(archived_at: nil).map { |db_project|
        Project.new(project: db_project)
      }
    end

    def each(&block)
      self.all.each do |db_project|
        block.(Project.new(project: db_project))
      end
    end

  end

  class AdrsFindable < Findable
    def all
      account = @args.fetch(:account)
      account.adrs
    end

    def search(tag:nil,project:nil)
      account = @args.fetch(:account)
      adrs = if tag.nil?
               account.adrs_dataset
             else
               tag = tag.downcase
               if (tag == DB::Adr.phony_tag_for_shared)
                 account.adrs_dataset.where(Sequel.lit("shareable_id IS NOT NULL"))
               else
                 account.adrs_dataset.where(Sequel.lit("tags @> ?",Sequel.pg_array([tag])))
               end
             end
      adrs = if project.nil?
               adrs
             else
               adrs.where(project_id: project.id)
             end
      adrs.to_a
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

  def projects
    ProjectsFindable.new(Project,account:)
  end

end
