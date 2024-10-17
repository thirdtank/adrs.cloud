class DownloadsWithExternalIdHandler < AppHandler
  def handle!(external_id:, authenticated_account:)
    download = Download.for_account(account:authenticated_account.account)
    if download.external_id != external_id
      return http_status(403)
    end
    Brut::FrontEnd::Download.new(
      timestamp: true,
      filename: "adrs-download.json",
      content_type: "applicatoin/json",
      data: download.all_data
    )
  end
end
