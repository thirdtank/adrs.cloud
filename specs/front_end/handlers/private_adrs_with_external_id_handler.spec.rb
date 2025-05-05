require "spec_helper"
RSpec.describe PrivateAdrsWithExternalIdHandler do
  describe "#handle!" do
    context "adr does not exist" do
      it "raises not found" do
        authenticated_account = create(:authenticated_account)
        flash = empty_flash
        handler = described_class.new(external_id: "foobar", authenticated_account: authenticated_account, flash: flash)
        expect {
          handler.handle!
        }.to raise_error(Brut::Framework::Errors::NotFound)
      end
    end
    context "adr exists" do
      context "account does not have access to it" do
        it "raises not found" do
          authenticated_account = create(:authenticated_account)
          adr = create(:adr)
          flash = empty_flash
          handler = described_class.new(external_id: adr.external_id, authenticated_account: authenticated_account, flash: flash)
          expect {
            handler.handle!
          }.to raise_error(Brut::Framework::Errors::NotFound)
        end
      end
      context "adr is shared" do
        it "clears the shareable_id" do
          authenticated_account = create(:authenticated_account)
          adr = create(:adr, :accepted, shareable_id: SecureRandom.uuid, account: authenticated_account.account)
          flash = empty_flash
          handler = described_class.new(external_id: adr.external_id, authenticated_account: authenticated_account, flash: flash)

          return_value = handler.handle!

          adr.reload

          expect(adr.shareable_id).to eq(nil)
          expect(flash[:notice]).to eq("sharing_stopped")
          expect(return_value).to be_routing_for(AdrsByExternalIdPage, external_id: adr.external_id)
        end
      end
      context "adr is not shared" do
        it "does nothing" do
          authenticated_account = create(:authenticated_account)
          adr = create(:adr, :accepted, shareable_id: nil, account: authenticated_account.account)
          flash = empty_flash
          handler = described_class.new(external_id: adr.external_id, authenticated_account: authenticated_account, flash: flash)

          return_value = handler.handle!

          adr.reload

          expect(adr.shareable_id).to eq(nil)
          expect(flash[:notice]).to eq("sharing_stopped")
          expect(return_value).to be_routing_for(AdrsByExternalIdPage, external_id: adr.external_id)
        end
      end
    end
  end
end
