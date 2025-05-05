class DownloadsHandler < AppHandler
  def initialize(authenticated_account:, flash:)
    @authenticated_account = authenticated_account
    @flash = flash
  end

  def handle
    download = Download.create(authenticated_account: @authenticated_account)
    download.save
    redirect_to(
      AccountByExternalIdPage, external_id: @authenticated_account.external_id, tab: "download"
    )
  end
end
