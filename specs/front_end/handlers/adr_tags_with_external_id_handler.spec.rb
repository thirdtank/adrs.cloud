require "spec_helper"
RSpec.describe AdrTagsWithExternalIdHandler do
  describe "#handle!" do
    context "adr does not exist" do
      it "raises not found" do
        account = create(:account)
        form = AdrTagsWithExternalIdForm.new
        external_id = "foobar"
        authenticated_account = AuthenticatedAccount.new(account: account)
        flash = empty_flash
        handler = described_class.new(form: form, external_id: external_id, authenticated_account: authenticated_account, flash: flash)
        expect {
          handler.handle!
        }.to raise_error(Brut::Framework::Errors::NotFound)
      end
    end
    context "adr exists" do
      context "account does not have access to it" do
        it "raises not found" do
          adr = create(:adr)
          account = create(:account)
          form = AdrTagsWithExternalIdForm.new
          external_id = adr.external_id
          authenticated_account = AuthenticatedAccount.new(account: account)
          flash = empty_flash
          handler = described_class.new(form: form, external_id: external_id, authenticated_account: authenticated_account, flash: flash)
          expect {
            handler.handle!
          }.to raise_error(Brut::Framework::Errors::NotFound)
        end
      end
      context "account has access" do
        it "updates the tags based on the form's string of tags" do
          adr = create(:adr, :accepted)
          account = adr.account
          form = AdrTagsWithExternalIdForm.new(params: { tags: "foo, bar\nBLAH" })
          external_id = adr.external_id
          authenticated_account = AuthenticatedAccount.new(account: account)
          flash = empty_flash
          handler = described_class.new(form: form, external_id: external_id, authenticated_account: authenticated_account, flash: flash)

          return_value = handler.handle!

          expect(return_value).to be_routing_for(AdrsByExternalIdPage, external_id: adr.external_id)

          adr.reload
          expect(adr.tags).to eq([ "foo", "bar", "blah" ])
        end
      end
    end
  end
end
