require "spec_helper"
RSpec.describe DownloadsHandler do
  subject(:handler) { described_class.new }
  describe "#handle!" do
    context "download already exists" do
      context "download is in progress" do
        it "does nothing" do
          authenticated_account = create(:authenticated_account)
          download              = create(:download, account: authenticated_account.account)

          result = nil
          expect {
            result = handler.handle!(authenticated_account:,flash:empty_flash)
          }.not_to change {
            DB::Download.count
          }

          expect(result).to be_routing_for(AccountByExternalIdPage,external_id: authenticated_account.external_id, tab: "download")
          download = DB::Download.find(id: download.id)
          expect(download).not_to eq(nil)
          expect(download.data_ready_at).to eq(nil)
        end
      end
      context "download is complete" do
        it "deletes the download and creates a new one" do
          authenticated_account = create(:authenticated_account)
          download              = create(:download, :ready, account: authenticated_account.account)

          result = handler.handle!(authenticated_account:,flash:empty_flash)

          expect(result).to be_routing_for(AccountByExternalIdPage,external_id: authenticated_account.external_id, tab: "download")
          download = DB::Download.find(id: download.id)
          expect(download).to eq(nil)
          expect(authenticated_account.account.download).not_to eq(nil)
          expect(authenticated_account.account.download.data_ready_at).to eq(nil)
        end
      end
    end
    context "no download" do
      it "creates a new one" do
        authenticated_account = create(:authenticated_account)

        result = handler.handle!(authenticated_account:,flash:empty_flash)

        expect(result).to be_routing_for(AccountByExternalIdPage,external_id: authenticated_account.external_id, tab: "download")
        expect(authenticated_account.account.download).not_to eq(nil)
        expect(authenticated_account.account.download.data_ready_at).to eq(nil)
      end
    end
  end
end
