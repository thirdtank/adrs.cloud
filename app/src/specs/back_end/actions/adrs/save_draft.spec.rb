require "spec_helper"
require "back_end/actions/adrs/save_draft"

RSpec.describe Actions::Adrs::SaveDraft do
  subject(:save_draft) { described_class.new }

  describe "#save_new" do
    context "form has an external_id in it" do
      it "raises a bug" do
        account = create(:account)
        form = Forms::Adrs::Draft.new(external_id: "foobar")
        expect {
          save_draft.save_new(form: form, account: account)
        }.to raise_error(Brut::BackEnd::Errors::Bug)
      end
    end
    context "there are constraint violations" do
      it "returns a result with the violations" do
        account = create(:account)
        form = Forms::Adrs::Draft.new(title: "aa")

        result = save_draft.save_new(form: form, account: account)

        expect(result.constraint_violations?).to eq(true)
        expect(result).to have_constraint_violation(:title, object: form, key: :not_enough_words)
      end
    end
    context "there are not constraint violations" do
      it "saves" do
        account = create(:account)
        form = Forms::Adrs::Draft.new(title: "This is a test")

        result = save_draft.save_new(form: form, account: account)

        expect(result.class).to eq(DataModel::Adr)
        expect(result.id).not_to eq(nil)
        adr = DataModel::Adr[id: result.id]
        expect(adr.title).to eq("This is a test")
        expect(adr.account.id).to eq(account.id)
        expect(adr.created_at).to be_within(1000).of(Time.now)
      end
      context "there is a refines_adr_external_id" do
        context "this account cannot access it" do
          it "sets refines_adr_id to nil" do
            adr_being_refined = create(:adr, :accepted)
            account = create(:account)
            form = Forms::Adrs::Draft.new(title: "This is a test", refines_adr_external_id: adr_being_refined.external_id)

            result = save_draft.save_new(form: form, account: account)

            expect(result.class).to eq(DataModel::Adr)
            expect(result.id).not_to eq(nil)
            adr = DataModel::Adr[id: result.id]
            expect(adr.title).to eq("This is a test")
            expect(adr.account.id).to eq(account.id)
            expect(adr.created_at).to be_within(1000).of(Time.now)
            expect(adr.refines_adr_id).to eq(nil)
          end
        end
        context "this account can access it" do
          it "saves it to the adr" do
            adr_being_refined = create(:adr, :accepted)
            account = adr_being_refined.account
            form = Forms::Adrs::Draft.new(title: "This is a test", refines_adr_external_id: adr_being_refined.external_id)

            result = save_draft.save_new(form: form, account: account)

            expect(result.class).to eq(DataModel::Adr)
            expect(result.id).not_to eq(nil)
            adr = DataModel::Adr[id: result.id]
            expect(adr.title).to eq("This is a test")
            expect(adr.account.id).to eq(account.id)
            expect(adr.created_at).to be_within(1000).of(Time.now)
            expect(adr.refines_adr_id).to eq(adr_being_refined.id)
          end
        end
      end
      context "there is a replaced_adr_external_id" do
        context "this account cannot access it" do
          it "does not create a proposed_adr_replacement" do
            adr_being_replaced = create(:adr, :accepted)
            account = create(:account)
            form = Forms::Adrs::Draft.new(title: "This is a test", replaced_adr_external_id: adr_being_replaced.external_id)

            result = save_draft.save_new(form: form, account: account)

            expect(result.class).to eq(DataModel::Adr)
            expect(result.id).not_to eq(nil)
            adr = DataModel::Adr[id: result.id]
            expect(adr.title).to eq("This is a test")
            expect(adr.account.id).to eq(account.id)
            expect(adr.created_at).to be_within(1000).of(Time.now)
            expect(adr.proposed_to_replace_adr).to eq(nil)
          end
        end
        context "this account can access it" do
          it "creates a proposed_adr_replacement" do
            adr_being_replaced = create(:adr, :accepted)
            account = adr_being_replaced.account
            form = Forms::Adrs::Draft.new(title: "This is a test", replaced_adr_external_id: adr_being_replaced.external_id)

            result = save_draft.save_new(form: form, account: account)

            expect(result.class).to eq(DataModel::Adr)
            expect(result.id).not_to eq(nil)
            adr = DataModel::Adr[id: result.id]
            expect(adr.title).to eq("This is a test")
            expect(adr.account.id).to eq(account.id)
            expect(adr.created_at).to be_within(1000).of(Time.now)
            expect(adr.proposed_to_replace_adr.id).to eq(adr_being_replaced.id)
          end
        end
      end
    end
  end

  describe "#update" do
    context "form has no external_id in it" do
      it "raises a bug" do
        account = create(:account)
        form = Forms::Adrs::Draft.new(external_id: nil)
        expect {
          save_draft.update(form: form, account: account)
        }.to raise_error(Brut::BackEnd::Errors::Bug)
      end
    end
    context "adr does not exist" do
      it "raises not found" do
        account = create(:account)
        form = Forms::Adrs::Draft.new(external_id: "foobar")
        expect {
          save_draft.update(form: form, account: account)
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
            save_draft.update(form: form, account: account)
          }.to raise_error(Brut::BackEnd::Errors::NotFound)
        end
      end
      context "account can access it" do
        context "there are constraint violations" do
          it "returns a result with the violations" do
            adr = create(:adr)
            account = adr.account
            form = Forms::Adrs::Draft.new(external_id: adr.external_id, title: "aa")

            result = save_draft.update(form: form, account: account)

            expect(result.constraint_violations?).to eq(true)
            expect(result).to have_constraint_violation(:title, object: form, key: :not_enough_words)
          end
        end
        context "there are not constraint violations" do
          it "saves, including parsing tags" do
            adr = create(:adr)
            account = adr.account
            form = Forms::Adrs::Draft.new(external_id: adr.external_id, title: "This is a test", tags: "foo, bar")

            result = save_draft.update(form: form, account: account)

            expect(result.class).to eq(DataModel::Adr)
            expect(result.id).to eq(adr.id)
            adr.reload
            expect(adr.title).to eq("This is a test")
            expect(adr.tags).to eq([ "foo", "bar" ])
          end
          context "there is a refines_adr_external_id" do
            context "this account cannot access it" do
              it "sets refines_adr_id to nil" do
                adr_being_refined = create(:adr, :accepted)
                adr = create(:adr)
                account = adr.account
                form = Forms::Adrs::Draft.new(external_id: adr.external_id, title: "This is a test", refines_adr_external_id: adr_being_refined.external_id)

                result = save_draft.update(form: form, account: account)

                expect(result.class).to eq(DataModel::Adr)
                expect(result.id).to eq(adr.id)
                adr.reload
                expect(adr.refines_adr_id).to eq(nil)
              end
            end
            context "this account can access it" do
              it "saves it to the adr" do
                adr_being_refined = create(:adr, :accepted)
                adr = create(:adr, account: adr_being_refined.account)
                account = adr.account
                form = Forms::Adrs::Draft.new(external_id: adr.external_id, title: "This is a test", refines_adr_external_id: adr_being_refined.external_id)

                result = save_draft.update(form: form, account: account)

                expect(result.class).to eq(DataModel::Adr)
                expect(result.id).to eq(adr.id)
                adr.reload
                expect(adr.refines_adr_id).to eq(adr_being_refined.id)
              end
            end
          end
          context "there is a replaced_adr_external_id" do
            context "this account cannot access it" do
              it "does not create a proposed_adr_replacement" do
                adr_being_replaced = create(:adr, :accepted)
                adr = create(:adr)
                account = adr.account
                form = Forms::Adrs::Draft.new(external_id: adr.external_id, title: "This is a test", replaced_adr_external_id: adr_being_replaced.external_id)

                result = save_draft.update(form: form, account: account)

                expect(result.class).to eq(DataModel::Adr)
                expect(result.id).to eq(adr.id)
                adr.reload
                expect(adr.proposed_to_replace_adr).to eq(nil)
              end
            end
            context "this account can access it" do
              it "creates a proposed_adr_replacement" do
                adr_being_replaced = create(:adr, :accepted)
                adr = create(:adr, account: adr_being_replaced.account)
                account = adr.account
                form = Forms::Adrs::Draft.new(external_id: adr.external_id, title: "This is a test", replaced_adr_external_id: adr_being_replaced.external_id)

                result = save_draft.update(form: form, account: account)

                expect(result.class).to eq(DataModel::Adr)
                expect(result.id).to eq(adr.id)
                adr.reload
                expect(adr.proposed_to_replace_adr.id).to eq(adr_being_replaced.id)
              end
            end
          end
        end
      end
    end
  end

end
