class ReadyDownloadsWithExternalIdHandler < AppHandler
  def handle!(external_id:, authenticated_account:)
    download = Download.for_account(account:authenticated_account.account)
    if download.external_id != external_id
      return http_status(403)
    end

    if download.ready?
      AccountByExternalIdPage::DownloadProgressComponent.new(download:)
    else
      http_status(404)
    end
  end
end
