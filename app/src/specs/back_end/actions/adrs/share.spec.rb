require "spec_helper"
require "back_end/actions/adrs/share"

RSpec.describe Actions::Adrs::Share do
  subject(:adrs_share) { described_class.new }

  describe "#share" do
    context "adr does not exist" do
      it "raises not found" do
        account = create(:account)
        expect {
          adrs_share.share(external_id: "foobar", account: account)
        }.to raise_error(Brut::BackEnd::Errors::NotFound)
      end
    end
    context "adr exists" do
      context "account does not have access to it" do
        it "raises not found" do
          adr = create(:adr)
          account = create(:account)
          expect {
            adrs_share.share(external_id: adr.external_id, account: account)
          }.to raise_error(Brut::BackEnd::Errors::NotFound)
        end
      end
      context "adr is shared" do
        it "sets a new shareable_id" do
          initial_shareable_id = SecureRandom.uuid
          adr = create(:adr, :accepted, shareable_id: initial_shareable_id)
          account = adr.account

          return_value = adrs_share.share(external_id: adr.external_id, account: account)

          adr.reload

          expect(adr.shareable_id).not_to eq(initial_shareable_id)
          expect(adr.shareable_id).not_to eq(nil)
          expect(return_value.id).to   eq(adr.id)
        end
      end
      context "adr is not shared" do
        it "sets a shareable_id" do
          adr = create(:adr, :accepted, shareable_id: nil)
          account = adr.account

          return_value = adrs_share.share(external_id: adr.external_id, account: account)

          adr.reload

          expect(adr.shareable_id).not_to eq(nil)
          expect(return_value.id).to   eq(adr.id)
        end
      end
    end
  end
  describe "#stop_sharing" do
    context "adr does not exist" do
      it "raises not found" do
        account = create(:account)
        expect {
          adrs_share.stop_sharing(external_id: "foobar", account: account)
        }.to raise_error(Brut::BackEnd::Errors::NotFound)
      end
    end
    context "adr exists" do
      context "account does not have access to it" do
        it "raises not found" do
          adr = create(:adr)
          account = create(:account)
          expect {
            adrs_share.stop_sharing(external_id: adr.external_id, account: account)
          }.to raise_error(Brut::BackEnd::Errors::NotFound)
        end
      end
      context "adr is shared" do
        it "clears the shareable_id" do
          adr = create(:adr, :accepted, shareable_id: SecureRandom.uuid)
          account = adr.account

          return_value = adrs_share.stop_sharing(external_id: adr.external_id, account: account)

          adr.reload

          expect(adr.shareable_id).to   eq(nil)
          expect(return_value.id).to eq(adr.id)
        end
      end
      context "adr is not shared" do
        it "does nothing" do
          adr = create(:adr, :accepted, shareable_id: nil)
          account = adr.account

          return_value = adrs_share.stop_sharing(external_id: adr.external_id, account: account)

          adr.reload

          expect(adr.shareable_id).to   eq(nil)
          expect(return_value.id).to eq(adr.id)
        end
      end
    end
  end
end
