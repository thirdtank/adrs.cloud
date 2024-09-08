require "spec_helper"
RSpec.describe SharedAdrsWithExternalIdHandler do
  subject(:handler) { described_class.new }
  describe "#handle!" do
    context "adr does not exist" do
      it "raises not found" do
        account = create(:account)
        expect {
          handler.handle!(external_id: "foobar", account: account, flash: empty_flash)
        }.to raise_error(Brut::BackEnd::Errors::NotFound)
      end
    end
    context "adr exists" do
      context "account does not have access to it" do
        it "raises not found" do
          adr = create(:adr)
          account = create(:account)
          expect {
            handler.handle!(external_id: adr.external_id, account: account, flash: empty_flash)
          }.to raise_error(Brut::BackEnd::Errors::NotFound)
        end
      end
      context "adr is shared" do
        it "sets a new shareable_id" do
          initial_shareable_id = SecureRandom.uuid
          adr = create(:adr, :accepted, shareable_id: initial_shareable_id)
          account = adr.account
          flash = empty_flash

          return_value = handler.handle!(external_id: adr.external_id, account: account, flash: flash)

          adr.reload

          expect(adr.shareable_id).not_to eq(initial_shareable_id)
          expect(adr.shareable_id).not_to eq(nil)
          expect(flash[:notice]).to eq(:adr_shared)
          expect(return_value).to be_routing_for(AdrsByExternalIdPage,external_id: adr.external_id)
        end
      end
      context "adr is not shared" do
        it "sets a shareable_id" do
          adr = create(:adr, :accepted, shareable_id: nil)
          account = adr.account
          flash = empty_flash

          return_value = handler.handle!(external_id: adr.external_id, account: account, flash: flash)

          adr.reload

          expect(adr.shareable_id).not_to eq(nil)
          expect(flash[:notice]).to eq(:adr_shared)
          expect(return_value).to be_routing_for(AdrsByExternalIdPage,external_id: adr.external_id)
        end
      end
    end
  end
end
