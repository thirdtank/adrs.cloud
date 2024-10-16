class Download

  extend Forwardable

  def self.for_account(account:)
    existing_download = account.download
    if existing_download
      Download.new(download: existing_download)
    else
      nil
    end
  end

  def self.create(authenticated_account:)
    existing_download = authenticated_account.account.download
    download = if existing_download.nil?
                 DB::Download.new(account: authenticated_account.account)
               elsif existing_download.data_ready_at.nil?
                 existing_download
               else
                 existing_download.delete
                 DB::Download.new(account: authenticated_account.account)
               end

    Download.new(download:)
  end

  def self.find!(external_id:,account:)
    download = DB::Download.find!(external_id:, account:)
    self.new(download:)
  end

  def initialize(download:)
    @download = download
  end

  def save
    @download.save
    CreateDownloadJob.perform_async(external_id)
  end

  def assemble
    @download.update(
      data_ready_at: Time.now,
      delete_at: Time.now + (60 * 60 * 24),
      all_data: @download.account.adrs.to_json
    )
  end

  def ready? = !@download.data_ready_at.nil?

  def_delegators :@download, :external_id, :created_at, :delete_at

end
