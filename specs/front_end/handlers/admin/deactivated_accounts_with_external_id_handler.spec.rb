require "spec_helper"
RSpec.describe Admin::DeactivatedAccountsWithExternalIdHandler do
  describe "#handle!" do
    context "authenticated_account is not an admin" do
      it "404s" do
        authenticated_account = create(:authenticated_account)
        account = create(:account)
        flash = empty_flash
        handler = described_class.new(external_id: account.external_id, flash: flash, authenticated_account: authenticated_account)

        result = handler.handle!

        expect(result).to have_returned_http_status(404)
      end
    end
    context "authenticated_account is an admin" do
      it "should deactivate the account and redirect to the homepage" do
        authenticated_account = create(:authenticated_account, :admin)
        account = create(:account)
        flash = empty_flash
        handler = described_class.new(external_id: account.external_id, flash: flash, authenticated_account: authenticated_account)

        result = handler.handle!
        account.reload

        expect(result).to be_routing_for(Admin::HomePage)
        expect(flash.notice).to eq("account_deactivated")
        expect(account.deactivated?).to eq(true)
      end
    end
  end
end
