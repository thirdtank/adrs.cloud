require "spec_helper"
RSpec.describe Admin::AccountEntitlementsWithExternalIdHandler do
  subject(:handler) { described_class.new }
  describe "#handle!" do
    context "entitlements could not be updated" do
      it "re-renders the page with the errors" do
        account = create(:account)
        form = Admin::AccountEntitlementsWithExternalIdForm.new(params: {
          max_non_rejected_adrs: "-1",
          external_id: account.external_id
        })
        result = handler.handle!(form:,external_id: account.external_id,flash: empty_flash)
        expect(form.constraint_violations?).to eq(true)
        expect(result.class).to eq(Admin::AccountsByExternalIdPage)
      end
    end
    context "entitlements were updated" do
      it "redirects to the admin account's page" do
        account = create(:account)
        form = Admin::AccountEntitlementsWithExternalIdForm.new(params: {
          max_non_rejected_adrs: "",
          external_id: account.external_id
        })
        flash = empty_flash
        expect(form.constraint_violations?).to eq(false),form.constraint_violations.inspect

        result = handler.handle!(form:,external_id: account.external_id,flash: flash)
        expect(result).to be_routing_for(Admin::AccountsByExternalIdPage, external_id: account.external_id)
        expect(flash.notice).to eq(:entitlements_saved)
      end
    end
  end
end
