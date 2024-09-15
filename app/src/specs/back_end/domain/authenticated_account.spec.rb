require "spec_helper"
RSpec.describe AuthenticatedAccount do
  describe "::search" do
    context "session id is not in the database" do
      it "returns nil" do
        result = AuthenticatedAccount.search(session_id: "blah")

        expect(result).to eq(nil)
      end
    end
    context "session id is in the database" do
      context "account is active" do
        it "returns an AuthenticatedAccount" do
          account = create(:account, :active)
          result = AuthenticatedAccount.search(session_id: account.external_id)

          expect(result).not_to eq(nil)
          expect(result.class).to eq(described_class)
        end
      end
      context "account is deactivated" do
        it "returns a DeactivateAccount" do
          account = create(:account, :deactivated)
          result = AuthenticatedAccount.search(session_id: account.external_id)

          expect(result).not_to eq(nil)
          expect(result.class).to eq(DeactivateAccount)
        end
      end
    end
  end

  describe "::new" do
    context "account is active" do
      it "returns an AuthenticatedAccount" do
        account = create(:account, :active)

        authenticated_account = AuthenticatedAccount.new(account:)
        expect(authenticated_account.active?).to eq(true)
        expect(authenticated_account.session_id).to eq(account.external_id)
      end
    end
    context "account is deactivated" do
      it "raises an ArgumentError" do
        account = create(:account, :deactivated)

        expect {
          AuthenticatedAccount.new(account:)
        }.to raise_error(ArgumentError)
      end
    end
  end
end
