require "spec_helper"
RSpec.describe Admin::DeactivatedAccountsWithExternalIdHandler do
  subject(:handler) { described_class.new }

  describe "#handle!" do
    it "should deactivate the account and redirect to the homepage" do
      account = create(:account)
      flash = empty_flash

      result = handler.handle!(external_id: account.external_id, flash:)
      account.reload

      expect(result).to be_routing_for(Admin::HomePage)
      expect(flash.notice).to eq(:account_deactivated)
      expect(account.deactivated?).to eq(true)
    end
  end
end
