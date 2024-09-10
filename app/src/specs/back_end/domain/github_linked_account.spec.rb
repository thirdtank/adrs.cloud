require "spec_helper"
RSpec.describe GithubLinkedAccount do
  describe "::find" do
    context "email is not in the database" do
      it "returns that it does not exist" do
        linked_account = GithubLinkedAccount.find(email: "nope@nope.nope")
        expect(linked_account.exists?).to eq(false)
      end
    end
    context "email is in the database" do
      context "account is not deactivated" do
        it "returns that it exists" do
          account = create(:account, deactivated_at: nil)
          linked_account = GithubLinkedAccount.find(email: account.email)
          expect(linked_account.exists?).to eq(true)
          expect(linked_account.account.id).to eq(account.id)
        end
      end
      context "account is deactivated" do
        it "returns that it does not exist" do
          account = create(:account, deactivated_at: Time.now)
          linked_account = GithubLinkedAccount.find(email: account.email)
          expect(linked_account.exists?).to eq(false)
        end
      end
    end
  end
  describe "#deactivate!" do
    context "active account" do
      it "sets deactivated_at and rotates their external_id" do
        account = create(:account, deactivated_at: nil)
        external_id = account.external_id
        github_linked_account = described_class.new(account:)
        github_linked_account.deactivate!

        account.reload
        expect(account.deactivated?).to eq(true)
        expect(account.external_id).not_to eq(external_id)
      end
    end
    context "deactivated account" do
      it "sets raises a bug" do
        account = create(:account, deactivated_at: Time.now)
        github_linked_account = described_class.new(account:)
        expect {
          github_linked_account.deactivate!
        }.to raise_error(Brut::BackEnd::Errors::Bug)
      end
    end
  end
end
