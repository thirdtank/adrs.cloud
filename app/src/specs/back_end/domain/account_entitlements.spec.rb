require "spec_helper"
RSpec.describe AccountEntitlements do
  describe "#can_add_new?" do
    context "account's max_non_rejected_adrs is null" do
      context "adrs is at the value" do
        it "is false" do
          account = create(:account)
          account.entitlement.update(max_non_rejected_adrs: nil)
          account.entitlement.entitlement_default.update(max_non_rejected_adrs: 2)
          create(:adr, account:)
          create(:adr, account:)
          create(:adr, account:, rejected_at: Time.now)
          expect(AccountEntitlements.new(account:).can_add_new?).to eq(false)
        end
      end
      context "adrs exceeds the value" do
        it "is false" do
          account = create(:account)
          account.entitlement.update(max_non_rejected_adrs: nil)
          account.entitlement.entitlement_default.update(max_non_rejected_adrs: 2)
          create(:adr, account:)
          create(:adr, account:)
          create(:adr, account:)
          create(:adr, account:, rejected_at: Time.now)
          expect(AccountEntitlements.new(account:).can_add_new?).to eq(false)
        end
      end
      context "adrs is less than the value" do
        it "is true" do
          account = create(:account)
          account.entitlement.update(max_non_rejected_adrs: nil)
          account.entitlement.entitlement_default.update(max_non_rejected_adrs: 2)
          create(:adr, account:)
          create(:adr, account:, rejected_at: Time.now)
          create(:adr, account:, rejected_at: Time.now)
          expect(AccountEntitlements.new(account:).can_add_new?).to eq(true)
        end
      end
    end
    context "account's max_non_rejected_adrs is not null" do
      context "adrs is at the value" do
        it "is false" do
          account = create(:account)
          account.entitlement.update(max_non_rejected_adrs: 2)
          create(:adr, account:)
          create(:adr, account:)
          create(:adr, account:, rejected_at: Time.now)
          expect(AccountEntitlements.new(account:).can_add_new?).to eq(false)
        end
      end
      context "adrs exceeds the value" do
        it "is false" do
          account = create(:account)
          account.entitlement.update(max_non_rejected_adrs: 2)
          create(:adr, account:)
          create(:adr, account:)
          create(:adr, account:)
          create(:adr, account:, rejected_at: Time.now)
          expect(AccountEntitlements.new(account:).can_add_new?).to eq(false)
        end
      end
      context "adrs is less than the value" do
        it "is true" do
          account = create(:account)
          account.entitlement.update(max_non_rejected_adrs: 2)
          create(:adr, account:)
          create(:adr, account:, rejected_at: Time.now)
          create(:adr, account:, rejected_at: Time.now)
          expect(AccountEntitlements.new(account:).can_add_new?).to eq(true)
        end
      end
    end
  end
end
