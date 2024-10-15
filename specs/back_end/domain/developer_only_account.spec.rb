require "spec_helper"
RSpec.describe DeveloperOnlyAccount do
  describe "::search" do
    it "returns the account if it exists" do
      account = create(:account)
      developer_only_account = described_class.find(email: account.email)

      expect(developer_only_account).not_to eq(nil)
      expect(developer_only_account.session_id).to eq(account.external_id)
    end

    it "returns nil if account does not exists" do
      expect(described_class.find(email: "foo@blah.com")).to eq(nil)
    end
  end
end
