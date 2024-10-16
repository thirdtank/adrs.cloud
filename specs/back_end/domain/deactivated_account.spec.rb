require "spec_helper"
RSpec.describe DeactivatedAccount do
  describe "::new" do
    context "account is deactivated" do
      it "creates without issue" do
        account = create(:account, :deactivated)

        deactivated_account = described_class.new(account:)

        expect(deactivated_account.active?).to eq(false)
        expect(deactivated_account.external_id).to eq(account.external_id)
      end
    end
    context "account is active" do
      it "raises ArgumentError" do
        account = create(:account, :active)

        expect {
          described_class.new(account:)
        }.to raise_error(ArgumentError)
      end
    end
  end
end
