require "spec_helper"
RSpec.describe DataModel::Entitlement do
  it "should not allow more than one per account" do
    default = create(:entitlement_default)
    account = create(:account, :without_entitlement)

    expect {
      described_class.create(account_id: account.id,
                             entitlement_default_id: default.id,
                             created_at: Time.now)
    }.not_to raise_error
    expect {
      described_class.create(account_id: account.id,
                             entitlement_default_id: default.id,
                             created_at: Time.now)
    }.to raise_error(/entitlements_account_id_key/)
  end
end
