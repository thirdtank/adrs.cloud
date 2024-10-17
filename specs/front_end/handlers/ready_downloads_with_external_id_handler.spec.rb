require "spec_helper"
RSpec.describe ReadyDownloadsWithExternalIdHandler do
  subject(:handler) { described_class.new }
  describe "#handle!" do
    context "external_id mismatch" do
      it "returns 403" do
        download = create(:download)
        account = download.account
        authenticated_account = AuthenticatedAccount.new(account:)
        some_other_download = create(:download)

        result = handler.handle!(external_id: some_other_download.external_id,authenticated_account:)
        expect(result.to_i).to eq(403)
      end
    end
    context "download not ready" do
      it "returns 404" do
        download = create(:download)
        account = download.account
        authenticated_account = AuthenticatedAccount.new(account:)

        result = handler.handle!(external_id: download.external_id,authenticated_account:)
        expect(result.to_i).to eq(404)
      end
    end
    context "download ready" do
      it "returns the download as an HTTP download" do
        download = create(:download, :ready)
        account = download.account
        authenticated_account = AuthenticatedAccount.new(account:)

        result = handler.handle!(external_id: download.external_id,authenticated_account:)
        expect(result.class).to eq(AccountByExternalIdPage::DownloadProgressComponent)
        expect(result.download.external_id).to eq(download.external_id)
      end
    end
  end
end
