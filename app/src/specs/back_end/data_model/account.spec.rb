require "spec_helper"

RSpec.describe DataModel::Account do
  describe "::create" do
    it "returns a new instance using the generated ID" do
      account = create(:account)
      account = described_class.create(email: Faker::Internet.unique.email, created_at: Time.now)
      expect(account.id).not_to eq(nil)
    end
  end
end
