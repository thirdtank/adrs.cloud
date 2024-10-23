require "spec_helper"
RSpec.describe Admin::AccountEntitlementsWithExternalIdHandler do
  subject(:handler) { described_class.new }
  describe "#handle!" do
    context "authenticated_account does not have admin access" do
      it "404s" do
        authenticated_account = create(:authenticated_account)
        account = create(:account)
        form = Admin::AccountEntitlementsWithExternalIdForm.new
        result = handler.handle!(form:,external_id: account.external_id,flash: empty_flash, authenticated_account:)
        expect(result).to have_returned_http_status(404)
      end
    end
    context "authenticated_account has admin access" do
      context "entitlements could not be updated" do
        it "re-renders the page with the errors" do
          authenticated_account = create(:authenticated_account, :admin)
          account = create(:account)
          form = Admin::AccountEntitlementsWithExternalIdForm.new(params: {
            max_non_rejected_adrs: "-1",
            external_id: account.external_id
          })
          result = handler.handle!(form:,external_id: account.external_id,flash: empty_flash, authenticated_account:)
          expect(form.constraint_violations?).to eq(true)
          expect(result.class).to eq(Admin::AccountsByExternalIdPage)
        end
      end
      context "entitlements were updated" do
        it "redirects to the admin account's page" do
          authenticated_account = create(:authenticated_account, :admin)
          account = create(:account)
          form = Admin::AccountEntitlementsWithExternalIdForm.new(params: {
            max_non_rejected_adrs: "",
            external_id: account.external_id
          })
          flash = empty_flash
          expect(form.constraint_violations?).to eq(false),form.constraint_violations.inspect

          result = handler.handle!(form:,external_id: account.external_id,flash: flash,authenticated_account:)
          expect(result).to be_routing_for(Admin::AccountsByExternalIdPage, external_id: account.external_id, authenticated_account:)
          expect(flash.notice).to eq(:entitlements_saved)
        end
      end
    end
  end
end
