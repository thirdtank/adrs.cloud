class AccountByExternalIdPage::DownloadProgressComponent < AppComponent
  attr_reader :download
  def initialize(download:)
    @download = download
  end
end
