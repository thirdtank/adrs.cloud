require "spec_helper"
RSpec.describe RejectedAdrsWithExternalIdHandler do
  subject(:handler) { described_class.new }

  describe "#handle!" do
    context "adr does not exist" do
      it "raises not found" do
        account = create(:account)
        expect {
          handler.handle!(external_id: "foobar", account: account, flash: empty_flash)
        }.to raise_error(Sequel::NoMatchingRow)
      end
    end
    context "adr exists" do
      context "account does not have access to it" do
        it "raises not found" do
          adr = create(:adr)
          account = create(:account)
          expect {
            handler.handle!(external_id: adr.external_id, account: account, flash: empty_flash)
          }.to raise_error(Sequel::NoMatchingRow)
        end

      end
      context "adr has been accepted" do
        it "raises not found" do
          adr = create(:adr, :accepted)
          account = adr.account
          expect {
            handler.handle!(external_id: adr.external_id, account: account, flash: empty_flash)
          }.to raise_error(Sequel::NoMatchingRow)
        end
      end
      context "adr has not been accepted" do
        context "adr has not been rejected" do
          it "sets rejected_at" do
            adr     = create(:adr)
            account = adr.account
            flash   = empty_flash

            return_value = handler.handle!(external_id: adr.external_id, account: account, flash: flash)

            expect(return_value).to be_routing_for(AdrsPage)
            expect(flash[:notice]).to eq(:adr_rejected)

            adr.refresh

            expect(adr.rejected_at).to be_within(1000).of(Time.now)
          end
        end

        context "adr has been rejected" do
          it "raises not found" do
            rejected_at = Time.now - 10_000
            adr = create(:adr, rejected_at: rejected_at)
            account = adr.account

            expect {
              handler.handle!(external_id: adr.external_id, account: , flash: empty_flash)
            }.to raise_error(Sequel::NoMatchingRow)
          end
        end
      end
    end
  end
end
