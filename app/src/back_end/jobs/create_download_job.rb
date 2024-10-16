class CreateDownloadJob
  include Sidekiq::Job
  def perform(external_id)
    download = Download.new(download: DB::Download.find!(external_id:))
    download.assemble
  end
end
