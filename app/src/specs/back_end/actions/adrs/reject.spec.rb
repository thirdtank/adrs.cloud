require "spec_helper"
require "back_end/actions/adrs/reject"

RSpec.describe Actions::Adrs::Reject do

  subject(:reject) { described_class.new }

  describe "#reject" do
    context "adr does not exist" do
      it "raises not found" do
        account = create(:account)
        form = Forms::Adrs::Draft.new(external_id: "foobar")
        expect {
          reject.reject(form: form, account: account)
        }.to raise_error(Brut::BackEnd::Errors::NotFound)
      end
    end
    context "adr exists" do
      context "account does not have access to it" do
        it "raises not found" do
          adr = create(:adr)
          account = create(:account)
          form = Forms::Adrs::Draft.new(external_id: adr.external_id)
          expect {
            reject.reject(form: form, account: account)
          }.to raise_error(Brut::BackEnd::Errors::NotFound)
        end

      end
      context "adr has been accepted" do
        it "raises bug" do
          adr = create(:adr, :accepted)
          account = adr.account
          form = Forms::Adrs::Draft.new(external_id: adr.external_id)
          expect {
            reject.reject(form: form, account: account)
          }.to raise_error(Brut::BackEnd::Errors::Bug)
        end
      end
      context "adr has not been accepted" do
        context "adr has not been rejected" do
          it "sets rejected_at" do
            adr = create(:adr)
            account = adr.account
            form = Forms::Adrs::Draft.new(external_id: adr.external_id)

            return_value = reject.reject(form: form, account: account)
            adr.refresh

            expect(adr.rejected_at).to be_within(1000).of(Time.now)
            expect(return_value.id).to eq(adr.id)
          end
        end

        context "adr has been rejected" do
          it "sets leaves rejected_at as it was" do
            rejected_at = Time.now - 10_000
            adr = create(:adr, rejected_at: rejected_at)
            account = adr.account
            form = Forms::Adrs::Draft.new(external_id: adr.external_id)

            return_value = reject.reject(form: form, account: account)
            adr.refresh

            expect(adr.rejected_at.to_i).to eq(rejected_at.to_i)
            expect(return_value.id).to eq(adr.id)
          end
        end
      end
    end
  end

end
