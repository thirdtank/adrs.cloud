require "spec_helper"
RSpec.describe RejectedAdrsWithExternalIdHandler do
  subject(:handler) { described_class.new }

  describe "#handle!" do
    context "adr does not exist" do
      it "raises not found" do
        authenticated_account = create(:authenticated_account)
        expect {
          handler.handle!(external_id: "foobar", authenticated_account:, flash: empty_flash)
        }.to raise_error(Sequel::NoMatchingRow)
      end
    end
    context "adr exists" do
      context "account does not have access to it" do
        it "raises not found" do
          authenticated_account = create(:authenticated_account)
          adr                   = create(:adr)

          expect {
            handler.handle!(external_id: adr.external_id, authenticated_account:, flash: empty_flash)
          }.to raise_error(Sequel::NoMatchingRow)
        end

      end
      context "adr has been accepted" do
        it "raises not found" do
          authenticated_account = create(:authenticated_account)
          adr                   = create(:adr, :accepted, account: authenticated_account.account)

          expect {
            handler.handle!(external_id: adr.external_id, authenticated_account:, flash: empty_flash)
          }.to raise_error(Sequel::NoMatchingRow)
        end
      end
      context "adr has not been accepted" do
        context "adr has not been rejected" do
          it "sets rejected_at" do
            authenticated_account = create(:authenticated_account)
            adr                   = create(:adr, account: authenticated_account.account)
            flash                 = empty_flash

            return_value = handler.handle!(external_id: adr.external_id, authenticated_account:, flash:)

            expect(return_value).to be_routing_for(AdrsPage)
            expect(flash[:notice]).to eq(:adr_rejected)

            adr.refresh

            expect(adr.rejected_at).to be_within(1000).of(Time.now)
          end
        end

        context "adr has been rejected" do
          it "raises not found" do
            authenticated_account = create(:authenticated_account)
            rejected_at           = Time.now - 10_000
            adr                   = create(:adr, rejected_at: rejected_at, account: authenticated_account.account)

            expect {
              handler.handle!(external_id: adr.external_id, authenticated_account: , flash: empty_flash)
            }.to raise_error(Sequel::NoMatchingRow)
          end
        end
      end
    end
  end
end
