require "spec_helper"
require "back_end/actions/adrs/accept"

RSpec.describe Actions::Adrs::Accept do

  subject(:accept) { described_class.new }

  describe "#accept" do
    context "adr does not exist" do
      it "raises not found" do
        account = create(:account)
        form = Forms::Adrs::Draft.new(external_id: "foobar")
        expect {
          accept.accept(form: form, account: account)
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
            accept.accept(form: form, account: account)
          }.to raise_error(Brut::BackEnd::Errors::NotFound)
        end
      end
      context "account can access it" do
        context "there are constraint violations" do
          it "returns a Brut::BackEnd::Actions::CheckResult indicating the problems" do
            adr = create(:adr)
            account = adr.account
            form = Forms::Adrs::Draft.new(external_id: adr.external_id, title: adr.title)

            result = accept.accept(form: form, account: account)

            expect(result.constraint_violations?).to eq(true)
            expect(result).to have_constraint_violation(:context, object: form, key: :required)
            expect(result).to have_constraint_violation(:facing, object: form, key: :required)
            expect(result).to have_constraint_violation(:decision, object: form, key: :required)
            expect(result).to have_constraint_violation(:neglected, object: form, key: :required)
            expect(result).to have_constraint_violation(:achieve, object: form, key: :required)
            expect(result).to have_constraint_violation(:accepting, object: form, key: :required)
            expect(result).to have_constraint_violation(:because, object: form, key: :required)
          end
        end
        context "there are no constraint violations" do
          context "it is not accepted" do
            it "sets accepted_at" do
              adr = create(:adr, :accepted, accepted_at: nil)
              account = adr.account
              form = Forms::Adrs::Draft.new(adr.to_hash)

              result = accept.accept(form: form, account: account)
              expect(result.class).to  eq(DataModel::Adr)
              adr.reload

              expect(adr.accepted_at).to be_within(1_000).of(Time.now)
            end
          end
          context "it is already accepted" do
            it "leaves accepted_at as it was" do
              accepted_at = Time.now - 10_000
              adr = create(:adr, :accepted, accepted_at: accepted_at)
              account = adr.account
              form = Forms::Adrs::Draft.new(adr.to_hash)

              result = accept.accept(form: form, account: account)
              expect(result.class).to  eq(DataModel::Adr)
              adr.reload

              expect(adr.accepted_at.to_i).to eq(accepted_at.to_i)
            end
          end
          context "it is intended to replace another ADR that is accepted" do
            it "sets that ADR as having been replaced by this one" do
              adr            = create(:adr, :accepted, accepted_at: nil)
              adr_to_replace = create(:adr, :accepted, account: adr.account)
              DataModel::ProposedAdrReplacement.create(
                replacing_adr_id: adr.id,
                replaced_adr_id: adr_to_replace.id,
                created_at: Time.now,
              )
              account = adr.account

              form = Forms::Adrs::Draft.new(adr.to_hash)

              result = accept.accept(form: form, account: account)
              expect(result.class).to  eq(DataModel::Adr)

              adr.reload
              adr_to_replace.reload

              expect(adr.accepted_at).to be_within(1_000).of(Time.now)
              expect(adr_to_replace.replaced_by_adr_id).to eq(adr.id)
            end
          end
        end
      end
    end
  end

end
