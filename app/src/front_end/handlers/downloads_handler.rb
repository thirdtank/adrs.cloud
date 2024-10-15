class DownloadsHandler < AppHandler
  def handle!(authenticated_account:, flash:)
    download = Download.create(authenticated_account:)
    download.save
    redirect_to(
      AccountByExternalIdPage,external_id: authenticated_account.external_id, tab: "download"
    )
  end
end
