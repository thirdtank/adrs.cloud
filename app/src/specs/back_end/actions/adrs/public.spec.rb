require "spec_helper"
require "back_end/actions/adrs/public"

RSpec.describe Actions::Adrs::Public do
  subject(:adrs_public) { described_class.new }

  describe "#make_public" do
    context "adr does not exist" do
      it "raises not found" do
        account = create(:account)
        expect {
          adrs_public.make_public(external_id: "foobar", account: account)
        }.to raise_error(Brut::BackEnd::Errors::NotFound)
      end
    end
    context "adr exists" do
      context "account does not have access to it" do
        it "raises not found" do
          adr = create(:adr)
          account = create(:account)
          expect {
            adrs_public.make_public(external_id: adr.external_id, account: account)
          }.to raise_error(Brut::BackEnd::Errors::NotFound)
        end
      end
      context "adr is public" do
        it "sets a new public id" do
          initial_public_id = SecureRandom.uuid
          adr = create(:adr, :accepted, public_id: initial_public_id)
          account = adr.account

          return_value = adrs_public.make_public(external_id: adr.external_id, account: account)

          adr.reload

          expect(adr.public_id).not_to eq(initial_public_id)
          expect(adr.public_id).not_to eq(nil)
          expect(return_value.id).to   eq(adr.id)
        end
      end
      context "adr is private" do
        it "sets a public id" do
          adr = create(:adr, :accepted, public_id: nil)
          account = adr.account

          return_value = adrs_public.make_public(external_id: adr.external_id, account: account)

          adr.reload

          expect(adr.public_id).not_to eq(nil)
          expect(return_value.id).to   eq(adr.id)
        end
      end
    end
  end
  describe "#make_private" do
    context "adr does not exist" do
      it "raises not found" do
        account = create(:account)
        expect {
          adrs_public.make_public(external_id: "foobar", account: account)
        }.to raise_error(Brut::BackEnd::Errors::NotFound)
      end
    end
    context "adr exists" do
      context "account does not have access to it" do
        it "raises not found" do
          adr = create(:adr)
          account = create(:account)
          expect {
            adrs_public.make_private(external_id: adr.external_id, account: account)
          }.to raise_error(Brut::BackEnd::Errors::NotFound)
        end
      end
      context "adr is public" do
        it "clears the public id" do
          adr = create(:adr, :accepted, public_id: SecureRandom.uuid)
          account = adr.account

          return_value = adrs_public.make_private(external_id: adr.external_id, account: account)

          adr.reload

          expect(adr.public_id).to   eq(nil)
          expect(return_value.id).to eq(adr.id)
        end
      end
      context "adr is private" do
        it "does nothing" do
          adr = create(:adr, :accepted, public_id: nil)
          account = adr.account

          return_value = adrs_public.make_private(external_id: adr.external_id, account: account)

          adr.reload

          expect(adr.public_id).to   eq(nil)
          expect(return_value.id).to eq(adr.id)
        end
      end
    end
  end
end
