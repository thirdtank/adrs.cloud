class DownloadsWithExternalIdHandler < AppHandler
  def initialize(external_id:, authenticated_account:)
    @external_id = external_id
    @authenticated_account = authenticated_account
  end

  def handle
    download = Download.for_account(account: @authenticated_account.account)
    if download.external_id != @external_id
      return http_status(403)
    end
    if download.ready?
      Brut::FrontEnd::Download.new(
        timestamp: true,
        filename: "adrs-download.html",
        content_type: "text/html",
        data: download.all_data
      )
    else
      http_status(404)
    end
  end
end
